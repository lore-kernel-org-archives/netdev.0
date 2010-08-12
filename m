From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: sky2 driver fails to handle "rx length error: status 0x5d60100
 length 2982" gracefully
Date: Thu, 12 Aug 2010 12:16:00 -0400
Message-ID: <20100812121600.2e971e66@s6510>
References: <AANLkTinMK7n51v4uBPYChYV7KOye8WEvdCFDanfd2mVL@mail.gmail.com>
	<20100811215932.26414efe@s6510>
	<AANLkTikDOerA4g+-=v+wM8cmysnemCTqEx0ncCCERLY6@mail.gmail.com>
	<20100812120044.5b1880ad@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	Linux NetDev <netdev@vger.kernel.org>
To: Maciej =?UTF-8?B?xbtlbmN6eWtvd3NraQ==?= <zenczykowski@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:38189 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752224Ab0HLQQE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Aug 2010 12:16:04 -0400
In-Reply-To: <20100812120044.5b1880ad@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> > Aug 11 16:21:19 nike kernel: sky2 0000:0c:00.0: eth0: rx length error:
> > status 0x5d60100 length 2982
> > Aug 11 16:21:27 nike kernel: eth0: hw csum failure.

Are you trying to run with Jumbo >1500 MTU?
