From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] appletalk: fix erroneous return value
Date: Thu, 18 Feb 2016 14:59:52 -0500 (EST)
Message-ID: <20160218.145952.821720367386006880.davem@davemloft.net>
References: <1455724439-10018-1-git-send-email-a.s.protopopov@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: acme@ghostprotocols.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: a.s.protopopov@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1455724439-10018-1-git-send-email-a.s.protopopov@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Anton Protopopov <a.s.protopopov@gmail.com>
Date: Wed, 17 Feb 2016 10:53:59 -0500

> The atalk_sendmsg() function might return wrong value ENETUNREACH
> instead of -ENETUNREACH.
> 
> Signed-off-by: Anton Protopopov <a.s.protopopov@gmail.com>

Applied.
