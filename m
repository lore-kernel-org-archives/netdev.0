From: Hans-Christian Egtvedt <hans-christian.egtvedt@atmel.com>
Subject: Re: [PATCH] at91_ether: Add Micrel KSZ8041 PHY support
Date: Wed, 17 Sep 2008 10:42:18 +0200
Message-ID: <20080917104218.08cee02e@atmel.com>
References: <cd73a99e0809161352s770e29fbs50b1b6995378211b@mail.gmail.com>
	<48D0BA01.3060104@marian.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andrew Victor <avictor.za@gmail.com>, netdev@vger.kernel.org,
	jgarzik@pobox.com, gustavo@zacarias.com.ar, kernel@avr32linux.org
To: Franco Fichtner <franco@marian.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat-132.atmel.no ([80.232.32.132]:64888 "EHLO relay.atmel.no"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751549AbYIQIm6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Sep 2008 04:42:58 -0400
In-Reply-To: <48D0BA01.3060104@marian.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 17 Sep 2008 10:04:17 +0200
Franco Fichtner <franco@marian.de> wrote:

> Andrew Victor wrote:

<snipp changelog for adding addition PHY support in AT91RM9200 driver>

> Added avr32 kernel list as CC.
> 

Hmm, for our information? AVR32 devices uses the drivers/net/macb.c
driver. And this driver uses the kernel PHY library.

-- 
Best regards,
Hans-Christian Egtvedt
