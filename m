From: David Miller <davem@davemloft.net>
Subject: Re: Dropping NETIF_F_SG since no checksum feature.
Date: Thu, 12 Oct 2006 21:22:40 -0700 (PDT)
Message-ID: <20061012.212240.26278742.davem@davemloft.net>
References: <20061011.144137.18281355.davem@davemloft.net>
	<20061012191206.GA16516@mellanox.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, steve@chygwyn.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	openib-general@openib.org, rolandd@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:43701
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751620AbWJMEWi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Oct 2006 00:22:38 -0400
To: mst@mellanox.co.il
In-Reply-To: <20061012191206.GA16516@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael S. Tsirkin" <mst@mellanox.co.il>
Date: Thu, 12 Oct 2006 21:12:06 +0200

> Quoting r. David Miller <davem@davemloft.net>:
> > Subject: Re: Dropping NETIF_F_SG since no checksum feature.
> > 
> > Numbers?
> 
> I created two subnets on top of the same pair infiniband HCAs:

I was asking for SG vs. non-SG numbers so I could see proof
that it really does help like you say it will.
