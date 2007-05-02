From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH 2/2] Rename get_property to of_get_property: drivers/net
Date: Wed, 2 May 2007 10:53:35 -0500
Message-ID: <9B877BC8-C064-4CD1-9325-5C3EA925346E@kernel.crashing.org>
References: <20070427145508.9c5641a2.sfr@canb.auug.org.au> <4633689E.50900@garzik.org> <20070429114446.31f40a30.sfr@canb.auug.org.au> <20070428.204754.62343452.davem@davemloft.net> <3802D7AD-67EC-4FA2-B361-A388AFCB0B94@kernel.crashing.org> <46389D85.7000301@garzik.org>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, sfr@canb.auug.org.au,
	paulus@samba.org, akpm@linux-foundation.org,
	linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nommos.sslcatacombnetworking.com ([67.18.224.114]:14646 "EHLO
	nommos.sslcatacombnetworking.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S2993405AbXEBPyn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2007 11:54:43 -0400
In-Reply-To: <46389D85.7000301@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On May 2, 2007, at 9:17 AM, Jeff Garzik wrote:

> Kumar Gala wrote:
>> On Apr 28, 2007, at 10:47 PM, David Miller wrote:
>>> From: Stephen Rothwell <sfr@canb.auug.org.au>
>>> Date: Sun, 29 Apr 2007 11:44:46 +1000
>>>
>>>> So can I take this as a future OK for architecture specific network
>>>> drivers changes to go through the architecture trees (cc'd to you)?
>>>
>>> It's been my experience that if I'm just working through some
>>> platform or bus specific API changes, people like Jeff tend to
>>> not mind if it goes via ARCH trees and the like.
>> Is this acceptable?   Just want to make sure before I ask Paul to  
>> pull some changes that touches the following drivers:
>> drivers/net/fs_enet/mac-scc.c           |    2 +-
>> drivers/net/ucc_geth.c                  |   30 ++++----
>> drivers/serial/cpm_uart/cpm_uart_cpm1.c |    4 +-
>> drivers/serial/cpm_uart/cpm_uart_cpm2.c |    4 +-
>
> I don't see a patch, just a diffstat.

I haven't sent a patch, just asking the question if I need to break  
it up or not.

- k
