From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net: wan : hdlc: use setup_timer() helper
Date: Thu, 21 Sep 2017 15:49:11 -0700 (PDT)
Message-ID: <20170921.154911.353339575349511897.davem@davemloft.net>
References: <1505998075-12969-1-git-send-email-allen.lkml@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, khc@pm.waw.pl, netdev@vger.kernel.org
To: allen.lkml@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1505998075-12969-1-git-send-email-allen.lkml@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Allen Pais <allen.lkml@gmail.com>
Date: Thu, 21 Sep 2017 18:17:55 +0530

>     Use setup_timer function instead of initializing timer with the
>     function and data fields.
> 
> Signed-off-by: Allen Pais <allen.lkml@gmail.com>

Applied.
