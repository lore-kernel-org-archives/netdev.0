From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v1] net: netcp: remove call to
 netif_carrier_(on/off) for MAC to Phy interface
Date: Sat, 25 Apr 2015 15:48:56 -0400 (EDT)
Message-ID: <20150425.154856.1696991150241343700.davem@davemloft.net>
References: <1429902101-2911-1-git-send-email-m-karicheri2@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: m-karicheri2@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1429902101-2911-1-git-send-email-m-karicheri2@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Murali Karicheri <m-karicheri2@ti.com>
Date: Fri, 24 Apr 2015 15:01:41 -0400

> Currently when interface type is MAC to Phy, netif_carrier_(on/off)
> is called which is not needed as Phy lib already updates the carrier
> status to net stack. This is needed only for other interface types
> 
> Signed-off-by: Murali Karicheri <m-karicheri2@ti.com>

net-next is not open for submissions yet
