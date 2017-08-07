From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] hamradio: baycom: make hdlcdrv_ops const
Date: Mon, 07 Aug 2017 14:26:58 -0700 (PDT)
Message-ID: <20170807.142658.2234739420522951674.davem@davemloft.net>
References: <1502009505-12973-1-git-send-email-bhumirks@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: julia.lawall@lip6.fr, t.sailer@alumni.ethz.ch,
        linux-hams@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: bhumirks@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1502009505-12973-1-git-send-email-bhumirks@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bhumika Goyal <bhumirks@gmail.com>
Date: Sun,  6 Aug 2017 14:21:45 +0530

> Make hdlcdrv_ops structures const as they are only passed to
> hdlcdrv_register function. The corresponding argument is of type const,
> so make the structures const.
> 
> Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>

Applied, thanks.
