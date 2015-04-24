From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH] net: netcp: remove call to netif_carrier_(on/off) for
 MAC to Phy interface
Date: Fri, 24 Apr 2015 11:25:04 +0530
Message-ID: <5539DAB8.4030803@ti.com>
References: <1429816627-24337-1-git-send-email-m-karicheri2@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
To: Murali Karicheri <m-karicheri2@ti.com>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>, <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1429816627-24337-1-git-send-email-m-karicheri2@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 24 April 2015 12:47 AM, Murali Karicheri wrote:
> Currently when interface type is MAC to Phy, netif_carrier_(on/off)
> is called which is not needed as Phy lib already updates the carrier
> status to net stack. This is needed only for other interface types
> 
> Signed-off-by: Murali Karicheri <m-karicheri2@ti.com>
> ---

Acked-by: Mugunthan V N <mugunthanvnm@ti.com>

Regards
Mugunthan V N
