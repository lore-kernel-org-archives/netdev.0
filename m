From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xfrm: Notify changes in UDP encapsulation via netlink
Date: Mon, 13 Oct 2008 03:03:11 -0700 (PDT)
Message-ID: <20081013.030311.248397621.davem@davemloft.net>
References: <20081013092726.49B34EFADF@strongswan.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: martin@strongswan.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43592
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932178AbYJMKDe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Oct 2008 06:03:34 -0400
In-Reply-To: <20081013092726.49B34EFADF@strongswan.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: martin@strongswan.org (Martin Willi)
Date: Mon, 13 Oct 2008 11:27:26 +0200 (CEST)

> Add new_mapping() implementation to the netlink xfrm_mgr to notify
> address/port changes detected in UDP encapsulated ESP packets.
> 
> Signed-off-by: Martin Willi <martin@strongswan.org>

This has to wait until the next merge window.

Please resubmit this 2 or so weeks from now, which is when I'll
likely start taking 2.6.29 bound networking stuff.
