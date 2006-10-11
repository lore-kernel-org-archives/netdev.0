From: David Miller <davem@davemloft.net>
Subject: Re: Dropping NETIF_F_SG since no checksum feature.
Date: Wed, 11 Oct 2006 14:41:37 -0700 (PDT)
Message-ID: <20061011.144137.18281355.davem@davemloft.net>
References: <20061011135720.303f166b@freekitty>
	<20061011212339.GH15468@mellanox.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, steve@chygwyn.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	openib-general@openib.org, rolandd@cisco.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1161528AbWJKVlk@vger.kernel.org>
To: mst@mellanox.co.il
In-Reply-To: <20061011212339.GH15468@mellanox.co.il>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael S. Tsirkin" <mst@mellanox.co.il>
Date: Wed, 11 Oct 2006 23:23:39 +0200

> With my patch, there is a huge performance gain by increasing MTU to 64K.
> And it seems the only way to do this is by S/G.

Numbers?
