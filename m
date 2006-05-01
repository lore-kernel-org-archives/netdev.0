From: Pavel Roskin <proski@gnu.org>
Subject: Re: [PATCH] Add some new card IDs to hostap_cs
Date: Mon, 01 May 2006 14:36:38 -0400
Message-ID: <1146508598.14309.24.camel@dv>
References: <20060501180425.GB32508@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Marcin Juszkiewicz <openembedded@hrw.one.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fencepost.gnu.org ([199.232.76.164]:21735 "EHLO
	fencepost.gnu.org") by vger.kernel.org with ESMTP id S1751274AbWEASgm
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 May 2006 14:36:42 -0400
Received: from proski by fencepost.gnu.org with local (Exim 4.34)
	id 1FadGD-0007e1-IL
	for netdev@vger.kernel.org; Mon, 01 May 2006 14:36:41 -0400
To: jt@hpl.hp.com, netdev@vger.kernel.org
In-Reply-To: <20060501180425.GB32508@bougret.hpl.hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-05-01 at 11:04 -0700, Jean Tourrilhes wrote:
> Marcin Juszkiewicz wrote :
> > 
> > When I use pcmcia-cs then my Pretec WiFi card is handled by hostap
> > driver and everything is working fine. Recently I switched to
> > pcmciautils and after card insert orinoco modules are loaded. I prefer
> > to use hostap modules because they work the same under 2.4 and 2.6
> > kernels (with orinoco I have to use 0.13e ones because never ones does
> > not work under 2.4/arm).
> 
> 	I'm sorry, but I have to veto part of your patch because it's
> clear you don't know what you are doing.
> 	Some of those cards are Orinoco or Symbol cards.

I agree.  Please don't apply this patch.

-- 
Regards,
Pavel Roskin

