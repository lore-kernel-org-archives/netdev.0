From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2/2] Rename get_property to of_get_property: drivers/net
Date: Wed, 02 May 2007 12:00:23 -0400
Message-ID: <4638B597.20604@garzik.org>
References: <20070427145508.9c5641a2.sfr@canb.auug.org.au> <4633689E.50900@garzik.org> <20070429114446.31f40a30.sfr@canb.auug.org.au> <20070428.204754.62343452.davem@davemloft.net> <3802D7AD-67EC-4FA2-B361-A388AFCB0B94@kernel.crashing.org> <46389D85.7000301@garzik.org> <9B877BC8-C064-4CD1-9325-5C3EA925346E@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, sfr@canb.auug.org.au,
	paulus@samba.org, akpm@linux-foundation.org,
	linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: Kumar Gala <galak@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:59571 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2993428AbXEBQAu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 May 2007 12:00:50 -0400
In-Reply-To: <9B877BC8-C064-4CD1-9325-5C3EA925346E@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kumar Gala wrote:
> 
> On May 2, 2007, at 9:17 AM, Jeff Garzik wrote:
> 
>> Kumar Gala wrote:
>>> On Apr 28, 2007, at 10:47 PM, David Miller wrote:
>>>> From: Stephen Rothwell <sfr@canb.auug.org.au>
>>>> Date: Sun, 29 Apr 2007 11:44:46 +1000
>>>>
>>>>> So can I take this as a future OK for architecture specific network
>>>>> drivers changes to go through the architecture trees (cc'd to you)?
>>>>
>>>> It's been my experience that if I'm just working through some
>>>> platform or bus specific API changes, people like Jeff tend to
>>>> not mind if it goes via ARCH trees and the like.
>>> Is this acceptable?   Just want to make sure before I ask Paul to 
>>> pull some changes that touches the following drivers:
>>> drivers/net/fs_enet/mac-scc.c           |    2 +-
>>> drivers/net/ucc_geth.c                  |   30 ++++----
>>> drivers/serial/cpm_uart/cpm_uart_cpm1.c |    4 +-
>>> drivers/serial/cpm_uart/cpm_uart_cpm2.c |    4 +-
>>
>> I don't see a patch, just a diffstat.
> 
> I haven't sent a patch, just asking the question if I need to break it 
> up or not.

Without seeing the patch, I have no idea...

	Jeff



