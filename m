From: Jan Engelhardt <jengelh@computergmbh.de>
Subject: Re: [PATCH] net/, drivers/net/ , missing EXPERIMENTAL in menus
Date: Fri, 31 Aug 2007 21:29:05 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0708312122550.9413@fbirervta.pbzchgretzou.qr>
References: <469E75AA.7040109@pimpmylinux.org>
 <Pine.LNX.4.64.0707181620460.13912@localhost.localdomain>
 <20070718134012.cde2f956.randy.dunlap@oracle.com> <469E7BE1.6090401@garzik.org>
 <Pine.LNX.4.64.0707181648330.15343@localhost.localdomain>
 <20070718210903.GM3801@stusta.de> <Pine.LNX.4.64.0707181712340.16513@localhost.localdomain>
 <20070719054742.GN3801@stusta.de> <Pine.LNX.4.64.0707190331330.11902@localhost.localdomain>
 <469F240E.9040205@s5r6.in-berlin.de> <Pine.LNX.4.64.0707190523001.19216@localhost.localdomain>
 <20070719083109.13b2ab56.rdunlap@xenotime.net>
 <Pine.LNX.4.64.0707191213130.8844@localhost.localdomain>
 <469FE045.3070403@simon.arlott.org.uk> <20070831102527.09fb42c0.rdunlap@xenotime.net>
 <Pine.LNX.4.64.0708311318220.18158@localhost.localdomain> <46D858A9.4080506@garzik.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Robert P. J. Day" <rpjday@mindspring.com>,
	Randy Dunlap <rdunlap@xenotime.net>,
	Simon Arlott <simon@fire.lp0.eu>, sam@ravnborg.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Stefan Richter <stefanr@s5r6.in-berlin.de>,
	Adrian Bunk <bunk@stusta.de>,
	Gabriel C <crazy@pimpmylinux.org>, netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sovereign.computergmbh.de ([85.214.69.204]:33283 "EHLO
	sovereign.computergmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750928AbXHaT3H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Aug 2007 15:29:07 -0400
In-Reply-To: <46D858A9.4080506@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Aug 31 2007 14:06, Jeff Garzik wrote:
>> something like BROKEN, though, has *nothing* to do with maturity.  a
>> feature can be any of those maturity levels, and simultaneously be
>> BROKEN.  i consider BROKEN to be what i call a "status", and different
>> status levels might be the default of normal, or KIND_OF_FLAKY or
>> TOTALLY_BORKED -- that's where BROKEN would fit in.
>
> BROKEN is definitely a maturity level.  A more accurate description would be
> BITROTTING perhaps.  The code in question has passed through bleeding ->
> experimental -> stable, and come out the other side.

Software is quite unlike the art of medicine. There, you would go from
'stable' to 'broken', then someone 'experiments' with you, and if
it's a bad day, you bleed out. :)


	Jan
-- 
