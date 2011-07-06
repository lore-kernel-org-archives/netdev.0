From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] b44: Use pr_<level>_once and DRV_DESCRIPTION
Date: Tue, 05 Jul 2011 20:45:46 -0700 (PDT)
Message-ID: <20110705.204546.433639330355698050.davem@davemloft.net>
References: <c57bb53427d6b56cf18ef7302033e58ef5eb92fb.1309887804.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zambrano@broadcom.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <c57bb53427d6b56cf18ef7302033e58ef5eb92fb.1309887804.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Tue,  5 Jul 2011 10:43:46 -0700

> Convert a printk with a static to pr_<level>_once
> Add and use DRV_DESCRIPTION to reduce string duplication.
> Remove now unused version.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied.
