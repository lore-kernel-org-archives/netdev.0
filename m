From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [2.6 patch] net/xfrm/: some cleanups
Date: Mon, 27 Dec 2004 19:01:33 -0800
Message-ID: <20041227190133.0fdfe915.davem@davemloft.net>
References: <20041212212523.GC22324@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jmorris@intercode.com.au, netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20041212212523.GC22324@stusta.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 12 Dec 2004 22:25:23 +0100
Adrian Bunk <bunk@stusta.de> wrote:

> The patch below contains the following changes:
> - make some needlessly global code static
> - remove the EXPORT_SYMBOL_GPL'ed but unused function 
>   xfrm_calg_get_byidx

Looks fine, applied.

Thanks Adrian.
