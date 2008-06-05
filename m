From: Geert Uytterhoeven <Geert.Uytterhoeven@sonycom.com>
Subject: Re: [PATCH 12/12]: wext: Emit event stream entries correctly when
 compat.
Date: Thu, 5 Jun 2008 09:43:08 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0806050940290.14577@vixen.sonytel.be>
References: <20080603.132856.202640855.davem@davemloft.net>
 <1212526129.14371.5.camel@johannes.berg> <20080603.135728.103448928.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-584349381-1031041274-1212651788=:14577"
Cc: johannes@sipsolutions.net, linux-wireless@vger.kernel.org,
	linville@tuxdriver.com, mokuno@sm.sony.co.jp,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vervifontaine.sonytel.be ([80.88.33.193]:36968 "EHLO
	vervifontaine.sonycom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752391AbYFEHnP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2008 03:43:15 -0400
In-Reply-To: <20080603.135728.103448928.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---584349381-1031041274-1212651788=:14577
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT

On Tue, 3 Jun 2008, David Miller wrote:
> > Did you miss drivers/net/ps3_gelic_wireless.c?
> 
> Likely yes, I guess that won't get hit with an allmodconfig
> build on sparc64 :(
> 
> It would be really nice if we had some more compat layers
> so that the ps3 bus probing layer just nopped out but you
> could at least build test drivers on other platforms.

That wouldn't help, as it runs on top of an hypervisor API.

The wired part may be merged back with spider_net one day...

With kind regards,

Geert Uytterhoeven
Software Architect

Sony Techsoft Centre
The Corporate Village · Da Vincilaan 7-D1 · B-1935 Zaventem · Belgium

Phone:    +32 (0)2 700 8453
Fax:      +32 (0)2 700 8622
E-mail:   Geert.Uytterhoeven@sonycom.com
Internet: http://www.sony-europe.com/

Sony Technology and Software Centre Europe
A division of Sony Service Centre (Europe) N.V.
Registered office: Technologielaan 7 · B-1840 Londerzeel · Belgium
VAT BE 0413.825.160 · RPR Brussels
Fortis 293-0376800-10 GEBA-BE-BB
---584349381-1031041274-1212651788=:14577--
