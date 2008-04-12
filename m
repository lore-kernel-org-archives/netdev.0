From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 1/3] sc92031: use net_device stats
Date: Sat, 12 Apr 2008 05:02:00 -0400
Message-ID: <48007A88.9010307@pobox.com>
References: <bug-10380-10286@http.bugzilla.kernel.org/> <20080402091435.39f99428.akpm@linux-foundation.org> <20080402094923.185f15dc@extreme> <20080402101120.67f8fa87@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Cesar Eduardo Barros <cesarb@cesarb.net>, tom@sharkbay.at,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:59394 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758622AbYDLJCG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Apr 2008 05:02:06 -0400
In-Reply-To: <20080402101120.67f8fa87@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> Statistics structure is available for use in net_device structure.
> Compile tested only.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> ---
> Patch against 2.6.25-rc8 with previous SET_NETDEV_DEV patch
> applied.

applied 1-3


