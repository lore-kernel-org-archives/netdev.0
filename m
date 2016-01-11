From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/rtnetlink: remove unused sz_idx variable
Date: Mon, 11 Jan 2016 00:22:44 -0500 (EST)
Message-ID: <20160111.002244.1465012641151344079.davem@davemloft.net>
References: <1452439617-17860-1-git-send-email-kuleshovmail@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.dichtel@6wind.com, roopa@cumulusnetworks.com,
	sfeldma@gmail.com, daniel@iogearbox.net, xiyou.wangcong@gmail.com,
	hannes@stressinduktion.org, eranbe@mellanox.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: kuleshovmail@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452439617-17860-1-git-send-email-kuleshovmail@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexander Kuleshov <kuleshovmail@gmail.com>
Date: Sun, 10 Jan 2016 21:26:57 +0600

> The sz_idx variable is defined in the rtnetlink_rcv_msg(), but
> not used anywhere. Let's remove it.
> 
> Signed-off-by: Alexander Kuleshov <kuleshovmail@gmail.com>

Applied, thanks.
