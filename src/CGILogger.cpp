/******************************************************************************
 * Copyright (C) 2007 Tetsuya Kimata <kimata@acapulco.dyndns.org>
 *
 * All rights reserved.
 *
 * This software is provided 'as-is', without any express or implied
 * warranty.  In no event will the authors be held liable for any
 * damages arising from the use of this software.
 *
 * Permission is granted to anyone to use this software for any
 * purpose, including commercial applications, and to alter it and
 * redistribute it freely, subject to the following restrictions:
 *
 * 1. The origin of this software must not be misrepresented; you must
 *    not claim that you wrote the original software. If you use this
 *    software in a product, an acknowledgment in the product
 *    documentation would be appreciated but is not required.
 *
 * 2. Altered source versions must be plainly marked as such, and must
 *    not be misrepresented as being the original software.
 *
 * 3. This notice may not be removed or altered from any source
 *    distribution.
 *
 * $Id: CGILogger.cpp,v 1.54 2009/02/08 01:59:46 kimata Exp $
 *****************************************************************************/

#include "Environment.h"

#include "CGILogger.h"
#include "SourceInfo.h"

SOURCE_INFO_ADD("$Id: CGILogger.cpp,v 1.54 2009/02/08 01:59:46 kimata Exp $");

CGILogger logger;

/******************************************************************************
 * public メソッド
 ****************************************************************************/
void CGILogger::info(const char *file, int line, void *, const char *format,
                     ...)
{
    va_list args;

    fprintf(stderr, "INFO: ");
    va_start(args, format);
    vfprintf(stderr, format, args);
    va_end(args);
    fprintf(stderr, " at %s:%d\n", file, line);
}

void CGILogger::warn(const char *file, int line, void *, const char *format,
                     ...)
{
    va_list args;

    fprintf(stderr, "WARN: ");
    va_start(args, format);
    vfprintf(stderr, format, args);
    va_end(args);
    fprintf(stderr, " at %s:%d\n", file, line);
}

void CGILogger::error(const char *file, int line, void *, const char *format,
                      ...)
{
    va_list args;

    fprintf(stderr, "ERROR: ");
    va_start(args, format);
    vfprintf(stderr, format, args);
    va_end(args);
    fprintf(stderr, " at %s:%d\n", file, line);
}

// Local Variables:
// mode: c++
// coding: utf-8-dos
// End:
