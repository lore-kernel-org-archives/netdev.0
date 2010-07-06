From: David Miller <davem@davemloft.net>
Subject: Re: [NET] ioc3-eth: Use the instance of net_device_stats from
 net_device.
Date: Mon, 05 Jul 2010 18:56:06 -0700 (PDT)
Message-ID: <20100705.185606.115922440.davem@davemloft.net>
References: <20100705125938.GB28849@linux-mips.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: segooon@gmail.com, kernel-janitors@vger.kernel.org,
	jpirko@redhat.com, eric.dumazet@gmail.com, kaber@trash.net,
	adobriyan@gmail.com, linux-mips@linux-mips.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: ralf@linux-mips.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100705125938.GB28849@linux-mips.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ralf Baechle <ralf@linux-mips.org>
Date: Mon, 5 Jul 2010 13:59:38 +0100

> Since net_device has an instance of net_device_stats, we can remove the
> instance of this from the adapter structure.
> 
> Based on original patch by Kulikov Vasiliy.
> 
> Signed-off-by: Ralf Baechle <ralf@linux-mips.org>
> Signed-off-by: Kulikov Vasiliy <segooon@gmail.com>

Applied.
