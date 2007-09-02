From: Adrian Bunk <bunk@kernel.org>
Subject: Re: Fwd: That whole "Linux stealing our code" thing
Date: Sun, 2 Sep 2007 15:12:26 +0200
Message-ID: <20070902131226.GN16016@stusta.de>
References: <f34ca13c0709010948v67b04b58lb098713dc38c4d6a@mail.gmail.com> <46D99FB7.6030505@garzik.org> <f34ca13c0709011037p221cb40fjf69651d1858df212@mail.gmail.com> <20070901205457.GK9260@stusta.de> <20070902113638.78fbd202@the-village.bc.nu> <Pine.LNX.4.64.0709021303001.4312@condmat1.ciencias.uniovi.es> <20070902115041.GM16016@stusta.de> <Pine.LNX.4.64.0709021416130.6181@condmat1.ciencias.uniovi.es> <20070902134612.28a88761@the-village.bc.nu> <Pine.LNX.4.64.0709021446550.6181@condmat1.ciencias.uniovi.es>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>,
	"Constantine A. Murenin" <mureninc@gmail.com>,
	Jeff Garzik <jeff@garzik.org>, linux-kernel@vger.kernel.org,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Jiri Slaby <jirislaby@gmail.com>
To: Igor Sobrado <igor@condmat1.ciencias.uniovi.es>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout.stusta.mhn.de ([141.84.69.5]:40905 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S965491AbXIBNMZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Sep 2007 09:12:25 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0709021446550.6181@condmat1.ciencias.uniovi.es>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Sep 02, 2007 at 03:00:46PM +0200, Igor Sobrado wrote:
> On Sun, 2 Sep 2007, Alan Cox wrote:
>
>>> So, a multi-licensed file remains multi-licensed except when all authors
>>> agree about a change in the licensing terms.  And it is clear on the BSD
>>
>> Not strictly true. They can either agree to a change and issue one or
>> they can convey to other parties the right to change the terms. The GPL
>> for example does this for version selection.
>
> So, under a dual-licensed BSD/GPL code the latter license allows a 
> developer to remove the GPL license itself and release a single-licensed 
> BSD code if other parties want to do it?


Exactly.


>> A multi-licensed work (note work not file - don't assume a file is a
>> boundary of a work) which conveys the choice of licence (as some bits of
>> ath5k did) allows a receiving party to choose the licence it wishes.
>> Failing that OpenBSD would have turned itself GPL by adding that file as
>> according to your argument "it must be distributed under *all* these
>> licensing terms concurrently".
>
> I would assume a file as a boundary of a work in the case that file is 
> under different licensing terms to the rest of the software package.  On a 
> lot of software packages different modules are covered under different 
> licensing terms.
>
> We can choose what license terms we will honor; however, we do not have the 
> ability to remove the licensing terms we do not like.


We have the ability if the author explicitely allowed it.

This is the licencing text we are talking about:


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


The author himself offered two _alternatives_ for distributing his code.


> Igor.

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

