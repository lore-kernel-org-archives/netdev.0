From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] smsc911x: Add check for ioremap_nocache() return code
Date: Wed, 12 Jul 2017 14:36:50 -0700 (PDT)
Message-ID: <20170712.143650.694091715091219972.davem@davemloft.net>
References: <1499893136-17013-1-git-send-email-khoroshilov@ispras.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steve.glendinning@shawell.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: khoroshilov@ispras.ru
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1499893136-17013-1-git-send-email-khoroshilov@ispras.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Date: Wed, 12 Jul 2017 23:58:56 +0300

> There is no check for return code of smsc911x_drv_probe()
> in smsc911x_drv_probe(). The patch adds one.
> 
> Found by Linux Driver Verification project (linuxtesting.org).
> 
> Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>

Applied, thanks.
