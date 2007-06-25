From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: Re: [2/2] 2.6.22-rc6: known regressions with patches
Date: Mon, 25 Jun 2007 11:48:19 +0200
Message-ID: <467F8F63.2070101@googlemail.com>
References: <467F894C.4000604@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Antonino Daplas <adaplas@gmail.com>,
	Olaf Hering <olaf@aepfle.de>,
	=?ISO-8859-2?Q?Ville_Syrj=E4l=E4?= <syrjala@sci.fi>,
	Christoph Lameter <clameter@sgi.com>,
	Dave Airlie <airlied@linux.ie>,
	Andrea Righi <righiandr@users.sourceforge.net>,
	Netdev <netdev@vger.kernel.org>, linux-wireless@vger.kernel.org,
	Samuel Ortiz <samuel@sortiz.org>,
	Andrey Borzenkov <arvidjaar@mail.ru>,
	Samuel Ortiz <samuel@sortiz.org>,
	Bjorn Helgaas <bjorn.helgaas@hp.com>,
	Chad Tindel <ctindel@users.sourceforge.net>,
	Olaf Hering <olaf@aepfle.de>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:52725 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753270AbXFYJsf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2007 05:48:35 -0400
Received: by ug-out-1314.google.com with SMTP id j3so1248665ugf
        for <netdev@vger.kernel.org>; Mon, 25 Jun 2007 02:48:35 -0700 (PDT)
In-Reply-To: <467F894C.4000604@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Here is a list of some known regressions in 2.6.22-rc6
with patches available.

=46eel free to add new regressions/remove fixed etc.
http://kernelnewbies.org/known_regressions

*STATISTICS* (a.k.a. list of aces)

Name                    Regressions fixed since 21-Jun-2007
Andi Kleen                             1
Hugh Dickins                           1
Jean Delvare                           1



=46BDEV

Subject    : mach64 breakage in 2.6.22
References : http://lkml.org/lkml/2007/6/14/73
Submitter  : Olaf Hering <olaf@aepfle.de>
Handled-By : Ville Syrj=E4l=E4 <syrjala@sci.fi>
Patch      : http://lkml.org/lkml/2007/6/21/216
Status     : patch was suggested



Memory management

Subject    : bug in i386 MTRR initialization
References : http://lkml.org/lkml/2007/5/19/93
Submitter  : Andrea Righi <righiandr@users.sourceforge.net>
Status     : patch available



Networking

Subject    : ERROR: "__ucmpdi2" [drivers/net/s2io.ko] undefined!
References : http://lkml.org/lkml/2007/6/19/310
Submitter  : Olaf Hering <olaf@aepfle.de>
Patch      : http://lkml.org/lkml/2007/6/19/382
Status     : patch was suggested

Subject    : no irda0 interface (2.6.21 was OK), smsc does not find chi=
p
References : http://lkml.org/lkml/2007/6/3/16
Submitter  : Andrey Borzenkov <arvidjaar@mail.ru>
Handled-By : Samuel Ortiz <samuel@sortiz.org>
             Bjorn Helgaas <bjorn.helgaas@hp.com>
Patch      : http://lkml.org/lkml/2007/6/7/237
Status     : patch was suggested



Regards,
Michal

--
LOG
http://www.stardust.webpages.pl/log/
