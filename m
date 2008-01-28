From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] [NET]: Remove PowerPC code from fec.c
Date: Mon, 28 Jan 2008 22:01:17 +0100
Message-ID: <200801282201.18658.arnd@arndb.de>
References: <4799F349.9090102@scram.de> <E1JIQpQ-0006Xj-RR@faramir.fjphome.nl> <479A087F.5010305@scram.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jochen Friedrich <jochen@scram.de>, Frans Pop <elendil@planet.nl>,
	linux-m68k@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, geert@linux-m68k.org,
	gerg@uclinux.org, scottwood@freescale.com, jgarzik@pobox.com
To: linuxppc-dev@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:58134 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761524AbYA1VBl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jan 2008 16:01:41 -0500
In-Reply-To: <479A087F.5010305@scram.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 25 January 2008, Jochen Friedrich wrote:
> Maybe the wording should be changed to:
> 
> This driver is now only used on ColdFire (m68knommu) processors. Conditional
> PowerPC code has been removed.
> 

How about adding a pointer to the driver that is now used on powerpc,
for the people that are looking in here?

	Arnd <><
