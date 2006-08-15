From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH] eth: indentation and cleanup
Date: Tue, 15 Aug 2006 16:34:07 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0608151633331.383@d.namei>
References: <20060815125759.590a4a44@dxpl.pdx.osdl.net>
 <20060815130245.5e11807b@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>,
	"Randy.Dunlap" <rdunlap@xenotime.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.sea5.speakeasy.net ([69.17.117.6]:4753 "EHLO
	mail4.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1750798AbWHOUeJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Aug 2006 16:34:09 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060815130245.5e11807b@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 15 Aug 2006, Stephen Hemminger wrote:

> -__be16 eth_type_trans(struct sk_buff *skb, struct net_device *dev)
> +__be16 eth_type_trans(struct sk_buff * skb, struct net_device * dev)


Looks fine except for this.



- James
-- 
James Morris
<jmorris@namei.org>
