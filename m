From: David Miller <davem@davemloft.net>
Subject: Re: [RESEND PATCH] net/socket.c : introduce helper function
 do_sock_sendmsg to replace reduplicate code
Date: Tue, 09 Dec 2014 15:24:50 -0500 (EST)
Message-ID: <20141209.152450.1137322945046835090.davem@davemloft.net>
References: <1416799125-13972-1-git-send-email-guz.fnst@cn.fujitsu.com>
	<54815B4F.50408@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: guz.fnst@cn.fujitsu.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54815B4F.50408@cn.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gu Zheng <guz.fnst@cn.fujitsu.com>
Date: Fri, 5 Dec 2014 15:14:23 +0800

> Introduce helper function do_sock_sendmsg() to simplify sock_sendmsg{_nosec},
> and replace reduplicate code.
> 
> Signed-off-by: Gu Zheng <guz.fnst@cn.fujitsu.com>

Applied, thanks.
