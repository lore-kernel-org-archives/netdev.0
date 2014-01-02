From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 13/25] hamradio: 6pack: fix error return code
Date: Thu, 02 Jan 2014 03:31:17 -0500 (EST)
Message-ID: <20140102.033117.1926462846239862157.davem@davemloft.net>
References: <1388357260-4843-1-git-send-email-Julia.Lawall@lip6.fr>
	<1388357260-4843-14-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ajk@comnets.uni-bremen.de, linux-hams@vger.kernel.org,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Julia.Lawall@lip6.fr
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <1388357260-4843-14-git-send-email-Julia.Lawall@lip6.fr>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>
Date: Sun, 29 Dec 2013 23:47:28 +0100

> From: Julia Lawall <Julia.Lawall@lip6.fr>
> 
> Set the return variable to an error code as done elsewhere in the function.
> 
> A simplified version of the semantic match that finds this problem is as
> follows: (http://coccinelle.lip6.fr/)
 ...
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

Applied.
