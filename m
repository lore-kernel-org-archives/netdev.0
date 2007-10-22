From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/4] Make and use skb_get_queue_mapping
Date: Sun, 21 Oct 2007 17:01:37 -0700 (PDT)
Message-ID: <20071021.170137.00474792.davem@davemloft.net>
References: <471871E5.7060900@openvz.org>
	<471872A7.7070101@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52731
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751297AbXJVABX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Oct 2007 20:01:23 -0400
In-Reply-To: <471872A7.7070101@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Fri, 19 Oct 2007 13:02:31 +0400

> Make the helper for getting the field, symmetrical to
> the "set" one. Return 0 if CONFIG_NETDEVICES_MULTIQUEUE=n
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
