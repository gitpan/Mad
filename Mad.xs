/*
 * Mad - perl mpeg decoder interface
 * Copyright (C) 2002 Mark McConnell
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 */

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include <mad.h>

/* pull in the two more complex interface headers */
#include "resample.h"
#include "dither.h"

/* now the constants that everything is in line */
#include "constants.h"

typedef struct mad_stream   * Mad_Stream;
typedef struct mad_frame    * Mad_Frame;
typedef struct mad_synth    * Mad_Synth;
typedef mad_timer_t         * Mad_Timer;
typedef struct mad_resample * Mad_Resample;
typedef struct mad_dither   * Mad_Dither;

MODULE = Mad		PACKAGE = Mad		
PROTOTYPES: ENABLE

double
constant(sv,arg)
    PREINIT:
	STRLEN		len;
    INPUT:
	SV *		sv
	char *		s = SvPV(sv, len);
	int		arg
    CODE:
	RETVAL = constant(s,len,arg);
    OUTPUT:
	RETVAL

MODULE = Mad		PACKAGE = Mad::Stream

Mad_Stream
new(CLASS)
		char *CLASS = NO_INIT;
	CODE:
		Newz(0, (void *)RETVAL, sizeof(*RETVAL), char);
		mad_stream_init(RETVAL);
	OUTPUT:
		RETVAL
		
void
buffer(THIS, data)
		Mad_Stream THIS
		SV* data
	PREINIT:
		unsigned char *ptr;
		STRLEN len;
	CODE:
		ptr = SvPV(data, len);
		mad_stream_buffer(THIS, ptr, (unsigned long)len);
		XSRETURN(1);
		
void
skip(THIS, length)
		Mad_Stream THIS
		unsigned long length
	CODE:
		mad_stream_skip(THIS, length);
		XSRETURN(1);
		
int
sync(THIS)
		Mad_Stream THIS
	CODE:
		RETVAL = mad_stream_sync(THIS);
	OUTPUT:
		RETVAL
		
size_t
this_frame(THIS)
		Mad_Stream THIS
	CODE:
		RETVAL = THIS->this_frame - THIS->buffer;
	OUTPUT:
		RETVAL
		
size_t
next_frame(THIS)
		Mad_Stream THIS
	CODE:
		RETVAL = THIS->next_frame - THIS->buffer;
	OUTPUT:
		RETVAL

int
error(THIS)
		Mad_Stream THIS
	CODE:
		RETVAL = THIS->error;
	OUTPUT:
		RETVAL
		
int
err_ok(THIS)
		Mad_Stream THIS
	CODE:
		RETVAL = MAD_RECOVERABLE(THIS->error);
	OUTPUT:
		RETVAL
		
void
DESTROY(THIS)
		Mad_Stream THIS;
	CODE:
		mad_stream_finish(THIS);
		Safefree(THIS);
		
MODULE = Mad		PACKAGE = Mad::Frame

Mad_Frame
new(CLASS)
		char *CLASS = NO_INIT;
	CODE:
		Newz(0, (void *)RETVAL, sizeof(*RETVAL), char);
		mad_frame_init(RETVAL);
	OUTPUT:
		RETVAL
		
int
decode(THIS, STREAM)
		Mad_Frame THIS
		Mad_Stream STREAM
	CODE:
		RETVAL = mad_frame_decode(THIS, STREAM);
	OUTPUT:
		RETVAL
		
int
decode_header(THIS, STREAM)
		Mad_Frame THIS
		Mad_Stream STREAM
	CODE:
		RETVAL = mad_header_decode(&THIS->header, STREAM);
	OUTPUT:
		RETVAL
		
void
mute(THIS)	
		Mad_Frame THIS
	CODE:
		mad_frame_mute(THIS);
		XSRETURN(1);
		
int 
layer(THIS)
		Mad_Frame THIS
	CODE:
		RETVAL = THIS->header.layer;
	OUTPUT:
		RETVAL

int 
mode(THIS)
		Mad_Frame THIS
	CODE:
		RETVAL = THIS->header.mode;
	OUTPUT:
		RETVAL

int 
bitrate(THIS)
		Mad_Frame THIS
	CODE:
		RETVAL = THIS->header.bitrate;
	OUTPUT:
		RETVAL

int 
samplerate(THIS)
		Mad_Frame THIS
	CODE:
		RETVAL = THIS->header.samplerate;
	OUTPUT:
		RETVAL

Mad_Timer
duration(THIS)
		Mad_Frame THIS
	CODE:
		Newz(0, (void *)RETVAL, sizeof(*RETVAL), char);
		*RETVAL = THIS->header.duration;
	OUTPUT:
		RETVAL

int
flags(THIS)
		Mad_Frame THIS
	CODE:
		RETVAL = THIS->header.flags;
	OUTPUT:
		RETVAL		
		
void
DESTROY(THIS)
		Mad_Frame THIS;
	CODE:
		mad_frame_finish(THIS);
		Safefree(THIS);

MODULE = Mad		PACKAGE = Mad::Synth

Mad_Synth
new(CLASS)
		char *CLASS = NO_INIT;
	CODE:
		Newz(0, (void *)RETVAL, sizeof(*RETVAL), char);
		mad_synth_init(RETVAL);
	OUTPUT:
		RETVAL

void
synth(THIS, FRAME)
		Mad_Synth THIS
		Mad_Frame FRAME
	CODE:
		mad_synth_frame(THIS, FRAME);
		XSRETURN(1);
		
void
samples(THIS)
		Mad_Synth THIS
	PREINIT:
		struct mad_pcm  *pcm;
	PPCODE:
		pcm = &THIS->pcm;
		if (!(pcm->length > 0)) {
			XSRETURN_UNDEF;
		}
		
		EXTEND(SP, 2);
		PUSHs(sv_2mortal(newSVpvn((char *)pcm->samples[0], sizeof(mad_fixed_t) * pcm->length)));
		if (pcm->channels == 2) {
			PUSHs(sv_2mortal(newSVpvn((char *)pcm->samples[1], sizeof(mad_fixed_t) * pcm->length)));
		}
			
void
mute(THIS)
		Mad_Synth THIS
	CODE:
		mad_synth_mute(THIS);
		XSRETURN(1);
		
void
DESTROY(THIS)
		Mad_Synth THIS;
	CODE:
		mad_synth_finish(THIS);
		Safefree(THIS);

MODULE = Mad		PACKAGE = Mad::Timer

Mad_Timer
new(CLASS, seconds=0, frac=0, denom=0)
		char *CLASS = NO_INIT;
		unsigned long seconds;
		unsigned long frac;
		unsigned long denom;
	CODE:
		Newz(0, (void *)RETVAL, sizeof(*RETVAL), char);
		*RETVAL = mad_timer_zero;

		if (items == 3)
			mad_timer_set(RETVAL, seconds, frac, denom);
	OUTPUT:
		RETVAL
		
Mad_Timer
new_copy(THIS)
		Mad_Timer THIS
	CODE:
		Newz(0, (void *)RETVAL, sizeof(*RETVAL), char);
		*RETVAL = *THIS;
	OUTPUT:
		RETVAL

void
set(THIS, seconds, frac, denom)
		Mad_Timer THIS
		unsigned long seconds
		unsigned long frac
		unsigned long denom
	CODE:
		mad_timer_set(THIS, seconds, frac, denom);
		XSRETURN(1);

void
reset(THIS)
		Mad_Timer THIS
	CODE:
		*THIS = mad_timer_zero;
		XSRETURN(1);
		
void
negate(THIS)
		Mad_Timer THIS
	CODE:
		mad_timer_negate(THIS);
		XSRETURN(1);
		
int
compare(THIS, OTHER)
		Mad_Timer THIS
		Mad_Timer OTHER
	CODE:
		RETVAL = mad_timer_compare(*THIS, *OTHER);
	OUTPUT:
		RETVAL
		
int 
sign(THIS)
		Mad_Timer THIS
	CODE:	
		RETVAL = mad_timer_compare(*THIS, mad_timer_zero);
	OUTPUT:
		RETVAL

void
abs(THIS)
		Mad_Timer THIS
	PREINIT:
		Mad_Timer ABS;
	CODE:
		*ABS  = mad_timer_abs(*THIS);
		*THIS = *ABS;
		XSRETURN(1);
		
void
add(THIS, OTHER)
		Mad_Timer THIS
		Mad_Timer OTHER
	CODE:
		mad_timer_add(THIS, *OTHER);
		XSRETURN(1);
		
void
multiply(THIS, value)
		Mad_Timer THIS
		long value
	CODE:
		mad_timer_multiply(THIS, value);
		XSRETURN(1);
		
long
count(THIS, units)
		Mad_Timer THIS
		int units
	CODE:
		RETVAL = mad_timer_count(*THIS, units);
	OUTPUT:
		RETVAL
		
unsigned long
fraction(THIS, denom)
		Mad_Timer THIS
		int denom
	CODE:
		RETVAL = mad_timer_fraction(*THIS, denom);
	OUTPUT:
		RETVAL
		
void
DESTROY(THIS)
		Mad_Timer THIS;
	CODE:
		Safefree(THIS);
		XSRETURN_UNDEF;

MODULE = Mad		PACKAGE = Mad::Resample

Mad_Resample
new(CLASS, oldrate=0, newrate=0)
		char *CLASS = NO_INIT;
		unsigned int oldrate
		unsigned int newrate
	CODE:
		Newz(0, (void *)RETVAL, sizeof(*RETVAL), char);
		mad_resample_init(RETVAL, oldrate, newrate);
	OUTPUT:
		RETVAL
		
unsigned int
init(THIS, oldrate=0, newrate=0)
		Mad_Resample THIS
		unsigned int oldrate
		unsigned int newrate
	CODE:
		mad_resample_init(THIS, oldrate, newrate);
		RETVAL = THIS->mode;
	OUTPUT:
		RETVAL
		
unsigned int
mode(THIS)
		Mad_Resample THIS
	CODE:	
		RETVAL = THIS->mode;
	OUTPUT:
		RETVAL
		
void
resample(THIS, left, right=&PL_sv_undef)
		Mad_Resample THIS
		SV *left
		SV *right
	PREINIT:
		unsigned int length, old_length, bufsize;
		mad_fixed_t *resampled, *data;
		double fscale;
	PPCODE:
		if (!SvPOK(left)) {
			XSRETURN_UNDEF;
		}
		
		/* this scale value,  and the following calculation
		   based upon it are gross displays of my infantile
		   C programming abilities.  basically,  I found out
		   the buffer _grows_ when you _upscale_ -- imagine
		   that (*smacks self*).  */
		fscale = mad_f_todouble(THIS->ratio);

		old_length = SvLEN(left) / sizeof(mad_fixed_t);
		/* so I spent an hour or two,  and thought of this
		   method of approximating a resulting buffer size
		   based upon the ratio scale value,  above.  If
		   there is a better way,  let me know.  This
		   can't be a good way of doing this. */
		bufsize = old_length * ((int)((double)1 / fscale) + 1);
		
		data = (mad_fixed_t *)SvPV_nolen(left);
		Newz(0, (void *)resampled, bufsize, mad_fixed_t);
			
		length = mad_resample_block(THIS, &THIS->state[0], old_length, data, resampled);
		PUSHs(sv_2mortal(newSVpvn((char *)resampled, sizeof(mad_fixed_t) * length)));
			
		if (right != &PL_sv_undef) {
			if (!SvPOK(right)) {
				XSRETURN_UNDEF;
			}
			
			old_length = SvLEN(right) / sizeof(mad_fixed_t);
			bufsize = old_length * ((int)((double)1 / fscale) + 1);
			/* ugh..  that always looks ugly..  but it works */
			
			data = (mad_fixed_t *)SvPV_nolen(right);
			Renew((void *)resampled, bufsize, mad_fixed_t);
			
			length = mad_resample_block(THIS, &THIS->state[1], old_length, data, resampled);
			PUSHs(sv_2mortal(newSVpvn((char *)resampled, sizeof(mad_fixed_t) * length)));
		}
		
		Safefree((void *)resampled);
		
void
DESTROY(THIS)
		Mad_Resample THIS;
	CODE:
		Safefree(THIS);
		XSRETURN_UNDEF;

MODULE = Mad		PACKAGE = Mad::Dither

Mad_Dither
new(CLASS, type=MAD_DITHER_S16_LE)
		char *CLASS = NO_INIT;
		int type
	CODE:
		Newz(0, (void *)RETVAL, sizeof(*RETVAL), char);
		mad_dither_init(RETVAL, type);
	OUTPUT:
		RETVAL
		
void
init(THIS, type=MAD_DITHER_S16_LE)
		Mad_Dither THIS
		int type
	CODE:
		mad_dither_init(THIS, type);
		XSRETURN_UNDEF;
		
void
dither(THIS, leftsv, rightsv=&PL_sv_undef)
		Mad_Dither THIS
		SV *leftsv
		SV *rightsv
	PREINIT:
		STRLEN old_length, length;
		mad_fixed_t *left, *right = NULL;
		unsigned char *cooked;
	PPCODE:
		if (THIS->pcmfunc == NULL) {
			XSRETURN_UNDEF;
		}
		
		if (!SvPOK(leftsv)) {
			XSRETURN_UNDEF;
		} 
		
		old_length = SvLEN(leftsv) / sizeof(mad_fixed_t);
		left = (mad_fixed_t *)SvPV_nolen(leftsv);
		if (!SvPOK(rightsv)) {
			length = old_length * THIS->pcmlength;
			Newz(0, (void *)cooked, length, char);
		} else {
			if (old_length != (SvLEN(rightsv) / sizeof(mad_fixed_t))) {
				XSRETURN_UNDEF;
			}
			length = old_length * THIS->pcmlength * 2;
			Newz(0, (void *)cooked, length, char);
			right = (mad_fixed_t *)SvPV_nolen(rightsv);
		}

		THIS->pcmfunc(&THIS->info, cooked, old_length, left, right);
		PUSHs(sv_2mortal(newSVpvn(cooked, length)));

		Safefree(cooked);
		
void
DESTROY(THIS)
		Mad_Dither THIS;
	CODE:
		Safefree(THIS);
		XSRETURN_UNDEF;
