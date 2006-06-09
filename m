From: "Randy.Dunlap" <rdunlap@xenotime.net>
Subject: Re: [RFT] Realtek 8168 ethernet support
Date: Thu, 8 Jun 2006 19:49:55 -0700
Message-ID: <20060608194955.7c583d72.rdunlap@xenotime.net>
References: <20060601200200.A0E0689D05D@zog.reactivated.net>
	<20060608143133.7e36a0b7.rdunlap@xenotime.net>
	<4488DF85.3090901@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: dsd@gentoo.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenotime.net ([66.160.160.81]:57763 "HELO xenotime.net")
	by vger.kernel.org with SMTP id S965108AbWFICrJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2006 22:47:09 -0400
Received: from midway.site ([71.245.102.105]) by xenotime.net for <netdev@vger.kernel.org>; Thu, 8 Jun 2006 19:47:07 -0700
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: <4488DF85.3090901@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 08 Jun 2006 22:40:05 -0400 Jeff Garzik wrote:

> Randy.Dunlap wrote:
> > Conversely, any reason to use the RealTek r1000 driver?
> 
> FWIW, RealTek emailed me about merging r1000.  I suggested that, if the 
> register sets were similar, that r8169 should be updated instead, to 
> preserve compatibility with existing users (and not lose existing work).

Sounds good to me.  I'm not terribly interested in seeing
multiple drivers for the same hardware in the kernel tree.

---
~Randy
