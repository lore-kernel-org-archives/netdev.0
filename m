From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 not working under latest kernels
Date: Fri, 17 May 2013 00:57:35 +0200
Message-ID: <20130516225735.GB20140@electric-eye.fr.zoreil.com>
References: <6901a7785249816fe13a98e3c0b35127@visp.net.lb>
 <678d818cc06d1da382dc14397ad41c7e@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hayeswang <hayeswang@realtek.com>, netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:38104 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754308Ab3EPW5m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 May 2013 18:57:42 -0400
Content-Disposition: inline
In-Reply-To: <678d818cc06d1da382dc14397ad41c7e@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denys Fedoryshchenko <denys@visp.net.lb> :
> On 2013-05-13 14:59, Denys Fedoryshchenko wrote:
[...]
> >Noticed on 32-builds of my systems that r8169 is not working
> >anymore at all.
> >Problem started to occur somewhere after 3.6 kernels, but it is
> >difficult to try other kernels on this semi-embedded system, and i am
> >not completely sure about that.
> >Once i used another OS build, but 64-bit build with same latest
> >kernel, and it worked.
[...]
> It is not only for that model, i faced this problem for many realtek
> cards. Probably as i mentioned something specific (such as ifplugd
> interface polling) causing that, but it is making almost all r8169
> cards unusable for me.

32-bit built KO vs 64-bit built OK does not ring a bell. I must go to
bed now but your .config and 32-bit r8169.ko will be welcome.

Thanks.

-- 
Ueimor
