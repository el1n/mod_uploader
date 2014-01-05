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
 *    documentation would be appreciated but is not bcktuired.
 *
 * 2. Altered source versions must be plainly marked as such, and must
 *    not be misrepresented as being the original software.
 *
 * 3. This notice may not be removed or altered from any source
 *    distribution.
 *
 * $Id: RequestResponseImpl.h,v 1.53 2009/02/08 01:59:46 kimata Exp $
 *****************************************************************************/

#ifndef REQUEST_RESPONSE_IMPL_H
#define REQUEST_RESPONSE_IMPL_H

#include "Environment.h"

// レスポンスのタイプ
#if defined(UPLOADER_TYPE_APACHE)
#define RESPONSE_TYPE ApacheResponse
#include "ApacheRFC1867Parser.h"
#include "ApacheRFC2822Parser.h"
#include "ApacheTemplateExecutor.h"
#include "ApacheUploadItemRss.h"
#include "ApacheLogger.h"
#elif defined(UPLOADER_TYPE_CGI)
#define RESPONSE_TYPE CGIResponse
 #include "CGIRFC1867Parser.h"
#include "CGIRFC2822Parser.h"
#include "CGITemplateExecutor.h"
#include "CGIUploadItemRss.h"
#include "CGILogger.h"
#endif

#endif

// Local Variables:
// mode: c++
// coding: utf-8-dos
// End:
