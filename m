From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/16] wan: lmc: fix error return code
Date: Tue, 07 Apr 2015 15:26:11 -0400 (EDT)
Message-ID: <20150407.152611.338150667973619545.davem@davemloft.net>
References: <1428235596-4757-1-git-send-email-Julia.Lawall@lip6.fr>
	<1428235596-4757-2-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Julia.Lawall@lip6.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1428235596-4757-2-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>
Date: Sun,  5 Apr 2015 14:06:21 +0200

> Return a negative error code on failure.
> 
> A simplified version of the semantic match that finds this problem is as
> follows: (http://coccinelle.lip6.fr/)
 ...
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

Applied.
