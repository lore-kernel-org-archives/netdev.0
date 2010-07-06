From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ethoc: Use the instance of net_device_stats from
 net_device.
Date: Mon, 05 Jul 2010 19:06:49 -0700 (PDT)
Message-ID: <20100705.190649.232765900.davem@davemloft.net>
References: <1278332012-16456-1-git-send-email-segooon@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, thomas@wytron.com.tw,
	jonas@southpole.se, eric.dumazet@gmail.com, julia@diku.dk,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: segooon@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1278332012-16456-1-git-send-email-segooon@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kulikov Vasiliy <segooon@gmail.com>
Date: Mon,  5 Jul 2010 16:13:31 +0400

> Since net_device has an instance of net_device_stats,
> we can remove the instance of this from the adapter structure.
> 
> Signed-off-by: Kulikov Vasiliy <segooon@gmail.com>

Applied.
