From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] connector: remove duplicated code in cn_call_callback()
Date: Mon, 03 Mar 2014 15:39:45 -0500 (EST)
Message-ID: <20140303.153945.218115412923126825.davem@davemloft.net>
References: <1393704056-13943-1-git-send-email-khoroshilov@ispras.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zbr@ioremap.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: khoroshilov@ispras.ru
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1393704056-13943-1-git-send-email-khoroshilov@ispras.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Date: Sun,  2 Mar 2014 00:00:56 +0400

> There were a couple of patches fixing the same bug that
> results in duplicated err = 0; assignment.
> The patch removes one of them.
> 
> Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>

Applied to net-next, thank you.
