/*
 * Replacement for the gethostname function for micro ports.
 * Copyright (c) 1996, 1996, 1997 Markku Rossi.
 *
 * Author: Markku Rossi <mtr@iki.fi>
 *
 * WIN32 changes by Dave Hylands <DHylands@creo.com>
 */

/*
 * This file is part of GNU Enscript.
 *
 * Enscript is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Enscript is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Enscript.  If not, see <http://www.gnu.org/licenses/>.
 */

#include <stdio.h>
#include <string.h>

#if defined( WIN32 )
/*
 * Define WIN32_LEAN_AND_MEAN so that we don't include WINSOCK.H which
 * has a conflicting definition of gethostname.
 */
#define	WIN32_LEAN_AND_MEAN
#include <windows.h>
#endif

int
gethostname (name, namelen)
     char *name;
     int namelen;
{
#if defined( WIN32 )
	char computerName[ MAX_COMPUTERNAME_LENGTH + 1 ];
	DWORD len = sizeof computerName;

	if ( GetComputerName (computerName, &len))
	{
		strncpy (name, computerName, namelen);
	}
	else
	{
        strncpy (name, "pc", namelen);
	}
	name[ namelen - 1 ] = 0;

#else
	strncpy (name, "pc", namelen);
#endif
  return 0;
}
