From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] gre: Fix wrong tpi->proto in WCCP
Date: Thu, 12 May 2016 16:54:35 -0400 (EDT)
Message-ID: <20160512.165435.581098847167435314.davem@davemloft.net>
References: <1462963712-13781-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
	<1462963712-13781-2-git-send-email-yanhaishuang@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xeb@mail.ru, kuznet@ms2.inr.ac.ru, kaber@trash.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: yanhaishuang@cmss.chinamobile.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1462963712-13781-2-git-send-email-yanhaishuang@cmss.chinamobile.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Date: Wed, 11 May 2016 18:48:32 +0800

> When dealing with WCCP in gre6 tunnel, it sets the wrong tpi->protocol,
> that is, ETH_P_IP instead of ETH_P_IPV6 for the encapuslated traffic.
> 
> Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>

Applied.
