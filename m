From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] X25: constify null_x25_address
Date: Thu, 03 Aug 2017 09:14:56 -0700 (PDT)
Message-ID: <20170803.091456.51242383561186627.davem@davemloft.net>
References: <1501666500-25911-1-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew.hendry@gmail.com, kernel-janitors@vger.kernel.org,
        linux-x25@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Julia.Lawall@lip6.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1501666500-25911-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>
Date: Wed,  2 Aug 2017 11:35:00 +0200

> null_x25_address is only used to access the string it contains, so it can
> be const.
> 
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

Applied, thanks.
