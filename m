From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] isdn: use constants instead of magicnumbers
Date: Thu, 24 Jul 2014 23:32:05 -0700 (PDT)
Message-ID: <20140724.233205.2150921422705096729.davem@davemloft.net>
References: <20140723211638.GA4283@himangi-Dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, julia.lawall@lip6.fr
To: himangi774@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140723211638.GA4283@himangi-Dell>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Himangi Saraogi <himangi774@gmail.com>
Date: Thu, 24 Jul 2014 02:46:38 +0530

> This patch changes instances of magic numbers like 4 and 8 to equivalent
> constants.
> 
> The Coccinelle semantic patch used for making the change is as follows:
 ...
> Signed-off-by: Himangi Saraogi <himangi774@gmail.com>
> Acked-by: Julia Lawall <julia.lawall@lip6.fr>

Applied, thank you.
