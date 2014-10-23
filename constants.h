static int
not_here(char *s)
{
    croak("%s not implemented on this architecture", s);
    return -1;
}

static double
constant_MAD_DITHER(char *name)
{
	if (strEQ(name, "S8"))
		return MAD_DITHER_S8;
	if (strEQ(name, "U8"))
		return MAD_DITHER_U8;
	if (strEQ(name, "S16_LE"))
		return MAD_DITHER_S16_LE;
	if (strEQ(name, "S16_BE"))
		return MAD_DITHER_S16_BE;
	if (strEQ(name, "S24_LE"))
		return MAD_DITHER_S24_LE;
	if (strEQ(name, "S24_BE"))
		return MAD_DITHER_S24_BE;		
	if (strEQ(name, "S32_LE"))
		return MAD_DITHER_S32_LE;
	if (strEQ(name, "S32_BE"))
		return MAD_DITHER_S32_BE;		
		
	errno = EINVAL;
	return 0;
}

static double
constant_MAD_FLAG(char *name)
{
	switch(name[0]) {
		case 'C':
			if (strEQ(name, "COPYRIGHT"))
				return MAD_FLAG_COPYRIGHT;
			break;
  		case 'F':
			if (strEQ(name, "FREEFORMAT"))
				return MAD_FLAG_FREEFORMAT;
			break;
		case 'I':
			if (strEQ(name, "INCOMPLETE"))
				return MAD_FLAG_INCOMPLETE;
			if (strEQ(name, "I_STEREO"))
				return MAD_FLAG_I_STEREO;
			break;
		case 'L':
			if (strEQ(name, "LSF_EXT"))
				return MAD_FLAG_LSF_EXT;
			break;
  		case 'M':
			if (strEQ(name, "MS_STEREO"))
				return MAD_FLAG_MS_STEREO;
			if (strEQ(name, "MC_EXT"))
				return MAD_FLAG_MC_EXT;
			if (strEQ(name, "MPEG_2_5_EXT"))
				return MAD_FLAG_MPEG_2_5_EXT;
			break;
		case 'N':
			if (strEQ(name, "NPRIVATE_III"))
				return MAD_FLAG_NPRIVATE_III;
			break;
  		case 'O':
			if (strEQ(name, "ORIGINAL"))
				return MAD_FLAG_ORIGINAL;
			break;
  		case 'P':
			if (strEQ(name, "PROTECTION"))
				return MAD_FLAG_PROTECTION;
			if (strEQ(name, "PADDING"))
				return MAD_FLAG_PADDING;
			break;
  		default:
	  		break;
  	}
  	
  	errno = EINVAL;
  	return 0;
}

static double
constant_MAD_ERROR(char *name) 
{
	switch (name[strlen(name) - 1]) {
		case 'A':
			if (strEQ(name, "BADHUFFDATA"))
				return MAD_ERROR_BADHUFFDATA;
			break;
		case 'C':
			if (strEQ(name, "LOSTSYNC"))
				return MAD_ERROR_LOSTSYNC;   
			if (strEQ(name, "BADCRC"))
				return MAD_ERROR_BADCRC;
			if (strEQ(name, "BADBITALLOC"))
				return MAD_ERROR_BADBITALLOC;
			break;
		case 'E':
			if (strEQ(name, "BADBITRATE"))
				return MAD_ERROR_BADBITRATE;
			if (strEQ(name, "BADSAMPLERATE"))
				return MAD_ERROR_BADSAMPLERATE;
			if (strEQ(name, "BADBLOCKTYPE"))
				return MAD_ERROR_BADBLOCKTYPE;
			if (strEQ(name, "BADHUFFTABLE"))
				return MAD_ERROR_BADHUFFTABLE;
			break;
		case 'I':
			if (strEQ(name, "BADSCFSI"))
				return MAD_ERROR_BADSCFSI;
			break;
		case 'M':
			if (strEQ(name, "NOMEM"))
				return MAD_ERROR_NOMEM;
			break;
		case 'N':
			if (strEQ(name, "BUFLEN"))
				return MAD_ERROR_BUFLEN;
			if (strEQ(name, "BADFRAMELEN"))
				return MAD_ERROR_BADFRAMELEN;
			if (strEQ(name, "BADPART3LEN"))
				return MAD_ERROR_BADPART3LEN;

		case 'O':
			if (strEQ(name, "BADSTEREO"))
				return MAD_ERROR_BADSTEREO;

		case 'R':
			if (strEQ(name, "BUFPTR"))
				return MAD_ERROR_BUFPTR;
			if (strEQ(name, "BADLAYER"))
				return MAD_ERROR_BADLAYER;
			if (strEQ(name, "BADSCALEFACTOR"))
				return MAD_ERROR_BADSCALEFACTOR;
			if (strEQ(name, "BADDATAPTR"))
				return MAD_ERROR_BADDATAPTR;
			break;
		case 'S':
			if (strEQ(name, "BADEMPHASIS"))
				return MAD_ERROR_BADEMPHASIS;
			if (strEQ(name, "BADBIGVALUES"))
				return MAD_ERROR_BADBIGVALUES;
			break;
		default:
			break;
	}
	
	errno = EINVAL;
	return 0;
}

static double
constant_MAD_UNITS(char *name)
{
	switch (name[0]) {
		case '1':
			if (strEQ(name, "11025_HZ"))
				return MAD_UNITS_11025_HZ;
			if (strEQ(name, "12000_HZ"))
				return MAD_UNITS_12000_HZ;
			if (strEQ(name, "16000_HZ"))
				return MAD_UNITS_16000_HZ;
			break;
		case '2':
			if (strEQ(name, "22050_HZ"))
				return MAD_UNITS_22050_HZ;
			if (strEQ(name, "24000_HZ"))
				return MAD_UNITS_24000_HZ;
			break;
		case '3':
			if (strEQ(name, "32000_HZ"))
				return MAD_UNITS_32000_HZ;
			break;
		case '4':
			if (strEQ(name, "44100_HZ"))
				return MAD_UNITS_44100_HZ;
			if (strEQ(name, "48000_HZ"))
				return MAD_UNITS_48000_HZ;
			break;
		case '8':
			if (strEQ(name, "8000_HZ"))
				return MAD_UNITS_8000_HZ;
			break;
		case 'C':
			if (strEQ(name, "CENTISECONDS"))
				return MAD_UNITS_CENTISECONDS;
			break;
		case 'D':
			if (strEQ(name, "DECISECONDS"))
				return MAD_UNITS_DECISECONDS;
			break;
		case 'H':
			if (strEQ(name, "HOURS"))
				return MAD_UNITS_HOURS;
			break;
		case 'M':
			if (strEQ(name, "MINUTES"))
				return MAD_UNITS_MINUTES;
			if (strEQ(name, "MILLISECONDS"))
				return MAD_UNITS_MILLISECONDS;
			break;
		case 'S':
			if (strEQ(name, "SECONDS"))
				return MAD_UNITS_SECONDS;
			break;
		default:
			break;
	}

	errno = EINVAL;
	return 0;
}

double
constant(char *name, STRLEN len, int arg)
{
	errno = 0;
	
	if (len < 4)
		goto not_there;
	
	switch(name[4]) {
		case 'D':
			if (strncmp(name, "MAD_DITHER_", 11) == 0) 
				return constant_MAD_DITHER(name + 11);
			break;
		case 'E':
			if (strncmp(name, "MAD_ERROR_", 10) == 0)
				return constant_MAD_ERROR(name + 10);
			break;
		case 'F':
			if (strncmp(name, "MAD_FLAG_", 9) == 0)
				return constant_MAD_FLAG(name + 9);
			if (strEQ(name, "MAD_F_ONE"))
				return MAD_F_ONE;
			if (strEQ(name, "MAD_F_MIN"))
				return MAD_F_MIN;
			if (strEQ(name, "MAD_F_FRACBITS"))
				return MAD_F_FRACBITS;
			if (strEQ(name, "MAD_F_MAX"))
				return MAD_F_MAX;
			break;
		case 'L':
			if (strEQ(name, "MAD_LAYER_I"))
				return MAD_LAYER_I;
			if (strEQ(name, "MAD_LAYER_II"))
				return MAD_LAYER_II;
			if (strEQ(name, "MAD_LAYER_III"))
				return MAD_LAYER_III;
			break;
		case 'M':
			if (strEQ(name, "MAD_MODE_SINGLE_CHANNEL"))
				return MAD_MODE_SINGLE_CHANNEL;
			if (strEQ(name, "MAD_MODE_DUAL_CHANNEL"))
				return MAD_MODE_DUAL_CHANNEL;
			if (strEQ(name, "MAD_MODE_JOINT_STEREO"))
				return MAD_MODE_JOINT_STEREO;
			if (strEQ(name, "MAD_MODE_STEREO"))
				return MAD_MODE_STEREO;
			break;
		case 'T':
			if (strEQ(name, "MAD_TIMER_RESOLUTION"))
				return MAD_TIMER_RESOLUTION;
			break;
		case 'U':
			if (strncmp(name, "MAD_UNITS_", 10) == 0)
				return constant_MAD_UNITS(name + 10);
			break;
		default:
			break;
	}
	errno = EINVAL;
	return 0;

not_there:
	errno = ENOENT;
	return 0;
}
