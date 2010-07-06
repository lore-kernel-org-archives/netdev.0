From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] davinci_emac: Use the instance of net_device_stats
 from net_device.
Date: Mon, 05 Jul 2010 19:06:42 -0700 (PDT)
Message-ID: <20100705.190642.70212655.davem@davemloft.net>
References: <1278332007-16175-1-git-send-email-segooon@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, chaithrika@ti.com, srk@ti.com,
	khilman@deeprootsystems.com, jpirko@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: segooon@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1278332007-16175-1-git-send-email-segooon@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kulikov Vasiliy <segooon@gmail.com>
Date: Mon,  5 Jul 2010 16:13:26 +0400

> Since net_device has an instance of net_device_stats,
> we can remove the instance of this from the adapter structure.
> 
> Signed-off-by: Kulikov Vasiliy <segooon@gmail.com>

Applied.
