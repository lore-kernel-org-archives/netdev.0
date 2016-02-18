From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: caif: fix erroneous return value
Date: Thu, 18 Feb 2016 14:59:57 -0500 (EST)
Message-ID: <20160218.145957.889804030878012756.davem@davemloft.net>
References: <1455724453-10064-1-git-send-email-a.s.protopopov@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dmitry.tarnyagin@lockless.no, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: a.s.protopopov@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1455724453-10064-1-git-send-email-a.s.protopopov@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Anton Protopopov <a.s.protopopov@gmail.com>
Date: Wed, 17 Feb 2016 10:54:13 -0500

> The cfrfml_receive() function might return positive value EPROTO
> 
> Signed-off-by: Anton Protopopov <a.s.protopopov@gmail.com>

Applied.
