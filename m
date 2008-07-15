From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tun: Fix/rewrite packet filtering logic
Date: Mon, 14 Jul 2008 22:16:02 -0700 (PDT)
Message-ID: <20080714.221602.232989530.davem@davemloft.net>
References: <1215852774-23974-1-git-send-email-maxk@qualcomm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rusty@rustcorp.com.au, jeff@garzik.org, netdev@vger.kernel.org,
	sjackman@gmail.com, linuxkernel@bristyle.com,
	virtualization@lists.linux-foundation.org, borntraeger@de.ibm.com
To: maxk@qualcomm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55398
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752714AbYGOFQC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2008 01:16:02 -0400
In-Reply-To: <1215852774-23974-1-git-send-email-maxk@qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Max Krasnyansky <maxk@qualcomm.com>
Date: Sat, 12 Jul 2008 01:52:54 -0700

> This is on top of the latest and greatest :). Assuming virt folks are ok with
> the API this should go into 2.6.27.

Really? :-)

It doesn't apply cleanly to net-next-2.6, as I just tried to
stick this into my tree.
