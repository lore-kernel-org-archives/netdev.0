From: David Miller <davem@davemloft.net>
Subject: Re: linux-2.6.30.1 with gcc-3.4.6 compile error
Date: Mon, 13 Jul 2009 11:11:57 -0700 (PDT)
Message-ID: <20090713.111157.59101216.davem@davemloft.net>
References: <9b5c9bb30907130944l3624870ck507f5a9f0f79452b@mail.gmail.com>
	<4A5B6F12.6030101@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: giamteckchoon@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756783AbZGMSLz@vger.kernel.org>
In-Reply-To: <4A5B6F12.6030101@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 13 Jul 2009 19:29:54 +0200

> [PATCH] igb: gcc-3.4.6 fix
> 
> forward declaration of inline function should be avoided, or
> old gcc cannot compile.
> 
> Reported-by: Teck Choon Giam <giamteckchoon@gmail.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks a lot Eric.
