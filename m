From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] tc35815: Fix an usage of streaming DMA API.
Date: Wed, 14 Mar 2007 05:59:51 -0400
Message-ID: <45F7C797.4030509@garzik.org>
References: <20070303.235459.25478204.anemo@mba.ocn.ne.jp>	<20070314.010220.65192616.anemo@mba.ocn.ne.jp>	<20070313120418.554a3a43@freekitty> <20070314.100557.33857330.nemoto@toshiba-tops.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, linux-mips@linux-mips.org,
	ralf@linux-mips.org, netdev@vger.kernel.org,
	sshtylyov@ru.mvista.com, akpm@linux-foundation.org
To: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:38972 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161006AbXCNJ76 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Mar 2007 05:59:58 -0400
In-Reply-To: <20070314.100557.33857330.nemoto@toshiba-tops.co.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Atsushi Nemoto wrote:
> On Tue, 13 Mar 2007 12:04:18 -0700, Stephen Hemminger <shemminger@linux-foundation.org> wrote:
>>> + *	1.35	Fix an usage of streaming DMA API.
>>>   */
>> Please don't use comments as changelog anymore. It gets out of date.
>> The use of change control systems has made this practice obsolete.
> 
> OK, Jeff, should I send a revised patch dropping this line?

Nah, there's no need to reject the patch on that basis.

You should send an additional patch, on top of all others you sent 
recently, that completely removes the entire changelog from the driver 
source code :)

	Jeff


