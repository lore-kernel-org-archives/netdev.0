From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 03/11] net: davinci_emac: fix error return code
Date: Tue, 25 Aug 2015 13:39:35 -0700 (PDT)
Message-ID: <20150825.133935.297421900575852606.davem@davemloft.net>
References: <1440288682-12732-1-git-send-email-Julia.Lawall@lip6.fr>
	<1440288682-12732-4-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Julia.Lawall@lip6.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1440288682-12732-4-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>
Date: Sun, 23 Aug 2015 02:11:14 +0200

> Propagate error code on failure.
> 
> A simplified version of the semantic match that finds this problem is as
> follows: (http://coccinelle.lip6.fr/)
 ...
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

Applied.
