From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] Move eth_mac_addr and eth_change_mtu
Date: Fri, 11 Jul 2003 16:57:21 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F0F24B1.5050200@pobox.com>
References: <20030711181946.GG20424@parcelfarce.linux.theplanet.co.uk> <20030711182330.GC16037@gtf.org> <20030711182530.GH20424@parcelfarce.linux.theplanet.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Matthew Wilcox <willy@debian.org>
In-Reply-To: <20030711182530.GH20424@parcelfarce.linux.theplanet.co.uk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Matthew Wilcox wrote:
> On Fri, Jul 11, 2003 at 02:23:30PM -0400, Jeff Garzik wrote:
> 
>>On Fri, Jul 11, 2003 at 07:19:46PM +0100, Matthew Wilcox wrote:
>>
>>>Move eth_mac_addr() and eth_change_mtu() from drivers/net/net_init.c
>>>to net/ethernet/eth.c
>>
>>Why?  It's not used outside of net_init.c AFAICS.
> 
> 
> Preparation for the next stage of netdev_ops


Well, I don't see/understand this next-stage, so elaboration would be 
nice.  As-is, I do not support merging this patch.

	Jeff
