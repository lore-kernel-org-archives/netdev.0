From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/13] Add basic VLAN support to bridges
Date: Tue, 29 Jan 2013 16:11:40 -0500 (EST)
Message-ID: <20130129.161140.2166884661210517263.davem@davemloft.net>
References: <1359489180-10012-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, bridge@lists.linux-foundation.org,
	netdev@vger.kernel.org, shmulik.ladkani@gmail.com
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60383 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750809Ab3A2VLm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2013 16:11:42 -0500
In-Reply-To: <1359489180-10012-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vyasevic@redhat.com>
Date: Tue, 29 Jan 2013 14:52:47 -0500

> This is another revision of the VLAN filtering patchset.  It offers
> functionality that is similar to what can be found in switches as
> far as VLAN configuration and filtering of frames according to VLAN
> tags.
> 
> Each port on the bridge, as well as the bridge itself, can be configured
> with a set of VLANs that they are willing to accept.  One of the vlans
> may be chosen as PVID and any untagged traffic will be associated with it.

I've done a quick review of this respin and it looks fine as far
as I can tell.

I'd like to apply it soon rather than let it rot in patchwork, so
Stephen if you could give this a once over soon I'd appreciate it.

Thanks.
