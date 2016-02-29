From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] 3c59x: Ensure to apply the expires time
Date: Sun, 28 Feb 2016 23:40:02 -0500 (EST)
Message-ID: <20160228.234002.1342033207865491608.davem@davemloft.net>
References: <CA+5yK5GF4mCZe8xeDwnj7QOz1m2xz2HOVkO59wdsBktZ3kmzYA@mail.gmail.com>
	<1456645769-2959-1-git-send-email-shorne@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	amitoj1606@gmail.com
To: shorne@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1456645769-2959-1-git-send-email-shorne@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stafford Horne <shorne@gmail.com>
Date: Sun, 28 Feb 2016 16:49:29 +0900

> In commit 5b6490def9168af6a ("3c59x: Use setup_timer()") Amitoj
> removed add_timer which sets up the epires timer.  In this patch
> the behavior is restore but it uses mod_timer which is a bit more
> compact.
> 
> Signed-off-by: Stafford Horne <shorne@gmail.com>

Applied, thanks.
