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
 * $Id: UploadClient.java,v 1.25 2009/02/08 01:59:46 kimata Exp $
 *****************************************************************************/

package org.dyndns.acapulco;

public class UploadClient {
    public static void main(String[] args) {
        System.setSecurityManager(null);

        UploadFrame frame = new UploadFrame();
        UploadController controller = new HTTPUploadController();

        frame.setController(controller);
        controller.setFrame(frame);

        frame.setVisible(true);
    }
}

// Local Variables:
// mode: java
// coding: utf-8-dos
// End:
