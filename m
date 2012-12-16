From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: tc ipt action
Date: Sun, 16 Dec 2012 20:13:57 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1212162003340.27614@nerf07.vanv.qr>
References: <50C4821D.5090206@gmail.com> <50C9B4BB.9060609@mojatatu.com> <50CCE961.5050204@mojatatu.com> <alpine.LNX.2.01.1212160002330.4901@nerf07.vanv.qr> <CAASe=fQT2pVOK0uctdaKL+aOrF8nYeTMfoF15kmd-rC02+7Vnw@mail.gmail.com> <50CDFB6A.3090806@mojatatu.com>
 <50CE1A04.1000405@mojatatu.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Hasan Chowdhury <shemonc@gmail.com>,
	Yury Stankevich <urykhy@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	pablo@netfilter.org, netfilter-devel@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ares07.inai.de ([5.9.24.206]:37184 "EHLO ares07.inai.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753215Ab2LPTOA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Dec 2012 14:14:00 -0500
In-Reply-To: <50CE1A04.1000405@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sunday 2012-12-16 19:59, Jamal Hadi Salim wrote:

> Hasan,
>
> I can confirm that xtables_options_xfrm() works.
> Just suspicious of that call, "xfrm" seems too specific to xfrm
> subsystem but generic enough.

Heh, nah.

"xfrm" is one of these pictogram-based abbreviations like "xing" (the 
thing they paint on roads/signs), apparently standing for "trans"form 
and "cross"ing, respectively, though 'x' is ambiguous and open to a lot 
of other interpretations.
