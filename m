From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 0/5]: [VLAN] fixes for PACKET
Date: Fri, 11 Apr 2008 15:04:22 +0200
Message-ID: <47FF61D6.3090206@trash.net>
References: <20080411092523.GA6873@tp64>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: auke-jan.h.kok@intel.com, davem@davemloft.net, jeff@garzik.org,
	netdev@vger.kernel.org
To: Joonwoo Park <joonwpark81@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:53936 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758041AbYDKNE0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Apr 2008 09:04:26 -0400
In-Reply-To: <20080411092523.GA6873@tp64>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joonwoo Park wrote:
> Hi,
> This patchset is the v3 for resolving the issue about VLAN & PACKET.
> It contains some cleanups for vlan as well.
> 
> Related previous discussions are below:
> http://bugzilla.kernel.org/show_bug.cgi?id=8218
> http://thread.gmane.org/gmane.linux.drivers.e1000.devel/2587
> http://thread.gmane.org/gmane.linux.network/88488
> 
> [PATCH 1/5] [VLAN]: Unclassified vlan packet
> [PATCH 2/5] [VLAN]: Add vlan tag into PACKET_AUXDATA
> [PATCH 3/5] [VLAN]: Use is_vlan_dev()
> [PATCH 4/5] [E1000]: [VLAN] Turn off the HW vlan filter if promisc
> [PATCH 5/5] [E1000e]: [VLAN] Turn off the HW vlan filter if promisc
> 
> Thanks Patrick for the suggestions.
> 
> Please review and consider applying.


Your patches don't seem to have made it to the list or my inbox.
