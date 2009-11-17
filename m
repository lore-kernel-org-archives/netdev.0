From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/5]net: PPP buffer too small for higher speed
 connections
Date: Tue, 17 Nov 2009 04:02:34 -0800 (PST)
Message-ID: <20091117.040234.245024359.davem@davemloft.net>
References: <fb8cc3511cffa.1cffafb8cc351@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	william.allen.simpson@gmail.com, jarkao2@gmail.com
To: huananhu@huawei.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755691AbZKQMCT@vger.kernel.org>
In-Reply-To: <fb8cc3511cffa.1cffafb8cc351@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: fangxiaozhi 00110321 <huananhu@huawei.com>
Date: Tue, 17 Nov 2009 19:59:05 +0800

> From: fangxiaozhi <huananhu@huawei.com>
> 1. This patch is based on the kernel of 2.6.32-rc7 
> 2. In this patch, we enlarge the out buffer size to optimize the upload speed for the ppp connection. Then it can support the upload of HSUPA data cards.
> Signed-off-by: fangxiaozhi <huananhu@huawei.com>

Applied to net-next-2.6, thanks.
