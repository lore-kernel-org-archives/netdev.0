From: Adrian Bunk <bunk@kernel.org>
Subject: Re: Fwd: That whole "Linux stealing our code" thing
Date: Sat, 1 Sep 2007 23:16:43 +0200
Message-ID: <20070901211642.GL9260@stusta.de>
References: <200709010140.l811eq9H005896@cvs.openbsd.org> <f34ca13c0709010948v67b04b58lb098713dc38c4d6a@mail.gmail.com> <46D99FB7.6030505@garzik.org> <f34ca13c0709011037p221cb40fjf69651d1858df212@mail.gmail.com> <20070901205457.GK9260@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Jeff Garzik <jeff@garzik.org>, linux-kernel@vger.kernel.org,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: "Constantine A. Murenin" <mureninc@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from emailhub.stusta.mhn.de ([141.84.69.5]:60823 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755939AbXIAVQl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Sep 2007 17:16:41 -0400
Content-Disposition: inline
In-Reply-To: <20070901205457.GK9260@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Sep 01, 2007 at 10:54:57PM +0200, Adrian Bunk wrote:
> On Sat, Sep 01, 2007 at 01:37:18PM -0400, Constantine A. Murenin wrote:
> > On 01/09/07, Jeff Garzik <jeff@garzik.org> wrote:
> > > Constantine A. Murenin wrote:
> > > > This will hopefully help diminish certain myths about the code licensing.
> > >
> > > What myth?  The myth that Theo understands dual licensing?
> > 
> > Reyk's code was never dual licensed, so it's not like it even matters
> > to the original dispute.

Oh, and if you look at the OpenBSD CVS you see versions 4 months old 
with dozens of contributions by Reyk and with:

/*      $OpenBSD: ath.c,v 1.63 2007/05/09 16:41:14 reyk Exp $  */
/*      $NetBSD: ath.c,v 1.37 2004/08/18 21:59:39 dyoung Exp $        */

/*-
 * Copyright (c) 2002-2004 Sam Leffler, Errno Consulting
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer,
 *    without modification.
 * 2. Redistributions in binary form must reproduce at minimum a disclaimer
 *    similar to the "NO WARRANTY" disclaimer below ("Disclaimer") and any
 *    redistribution must be conditioned upon including a substantially
 *    similar Disclaimer requirement for further binary redistribution.
 * 3. Neither the names of the above-listed copyright holders nor the names
 *    of any contributors may be used to endorse or promote products derived
 *    from this software without specific prior written permission.
 *
 * Alternatively, this software may be distributed under the terms of the
 * GNU General Public License ("GPL") version 2 as published by the Free
 * Software Foundation.
 *
 * NO WARRANTY
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF NONINFRINGEMENT, MERCHANTIBILITY
 * AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
 * THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR SPECIAL, EXEMPLARY,
 * OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
 * IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
 * THE POSSIBILITY OF SUCH DAMAGES.
 */

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

