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
 * $Id: MultipartMessageParserBuffer.cpp,v 1.54 2009/02/08 01:59:46 kimata Exp $
 *****************************************************************************/

#include "Environment.h"

#include "MultipartMessageParserBuffer.h"

const apr_size_t MultipartMessageParserBuffer::DEFAULT_SIZE  = 1024;

/******************************************************************************
 * public メソッド
 *****************************************************************************/
MultipartMessageParserBuffer::MultipartMessageParserBuffer(apr_size_t size)
  : buffer_(NULL),
    size_(0)
{
    reserve(size);
}

MultipartMessageParserBuffer::~MultipartMessageParserBuffer()
{
    if (buffer_  != NULL) {
        free(buffer_);
    }
}

void MultipartMessageParserBuffer::reserve(apr_size_t size)
{
    char *swap;

#ifdef DEBUG
    if (size < size_) {
        THROW(MESSAGE_BUG_FOUND);
    }
#endif

    if (size == 0) {
        return;
    }

    if (buffer_ == NULL) {
        MALLOC(buffer_, char *, sizeof(char), size);
    } else {
        swap = buffer_;

        try {
            MALLOC(buffer_, char *, sizeof(char), size);
            memcpy(buffer_, swap, size_);
            free(swap);
        } catch(const char *) {
            free(swap);
            throw;
        }
    }
    buffer_size_ = size;
}

// Local Variables:
// mode: c++
// coding: utf-8-dos
// End:
