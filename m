From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [2.6 patch] net/core/: misc possible cleanups
Date: Mon, 27 Dec 2004 19:02:49 -0800
Message-ID: <20041227190249.6afda3df.davem@davemloft.net>
References: <20041214045758.GA23151@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20041214045758.GA23151@stusta.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 14 Dec 2004 05:57:58 +0100
Adrian Bunk <bunk@stusta.de> wrote:

>   - skbuff.c: skb_insert
>   - skbuff.c: skb_iter_first
>   - skbuff.c: skb_iter_next
>   - skbuff.c: skb_iter_abort

These are actually planned to be used, let's keep them in for
now.
