From: David Miller <davem@davemloft.net>
Subject: Re: tg3: transmit timed out, resetting
Date: Mon, 11 Jun 2012 16:42:39 -0700 (PDT)
Message-ID: <20120611.164239.604207264181849443.davem@davemloft.net>
References: <1338955977.2760.3603.camel@edumazet-glaptop>
	<CABawtvOBJQ-oajFQmviOdgKCub-4n06kRW+x7nE2uyiWnoky9Q@mail.gmail.com>
	<20120607225654.GA14247@mcarlson.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ethan.kernel@gmail.com, eric.dumazet@gmail.com,
	lists@nerdbynature.de, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: mcarlson@broadcom.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120607225654.GA14247@mcarlson.broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Thu, 7 Jun 2012 15:56:54 -0700

> Does the following patch fix your problem?
> 
> 
> [PATCH] tg3: Apply short DMA frag workaround to 5906
> 
> 5906 devices also need the short DMA fragment workaround.  This patch
> makes the necessary change.
> 
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>

Ping, what's the status of this?
