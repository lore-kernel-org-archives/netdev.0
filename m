From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][NEIGH]: Fix race between pneigh deletion and ipv6's
 ndisc_recv_ns.
Date: Tue, 11 Mar 2008 17:52:12 -0700 (PDT)
Message-ID: <20080311.175212.74407707.davem@davemloft.net>
References: <47CFD2ED.3060207@openvz.org>
	<47D68817.9030709@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45820
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751141AbYCLAwG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Mar 2008 20:52:06 -0400
In-Reply-To: <47D68817.9030709@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Tue, 11 Mar 2008 16:24:39 +0300

> You picked up the patch with /proc/net symlink, but skipped this
> one, while it was sent earlier. Is it _that_ bad :) ?

I am travelling and giving presentations in Japan, and
this patch is in my backlog to look at :-)
