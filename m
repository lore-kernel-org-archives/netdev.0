From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/2] net: l3mdev: Allow send on enslaved
 interface
Date: Mon, 09 May 2016 22:34:11 -0400 (EDT)
Message-ID: <20160509.223411.1458387886462642527.davem@davemloft.net>
References: <1462664940-26678-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36188 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751131AbcEJCeR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2016 22:34:17 -0400
In-Reply-To: <1462664940-26678-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Sat,  7 May 2016 16:48:58 -0700

> First patch preps for the second. The second is required for several use
> cases such as ping on an interface and BFD that need to send packets on
> a specific interface, including ones enslaved to a VRF device.
> 
> v2
> - fixed brackets on both patches per comment from DaveM

Series applied.
