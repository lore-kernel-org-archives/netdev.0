From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [2.6 patch] net/sched/: possible cleanups
Date: Mon, 27 Dec 2004 21:19:11 -0800
Message-ID: <20041227211911.66c0b643.davem@davemloft.net>
References: <20041215012754.GH12937@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20041215012754.GH12937@stusta.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 15 Dec 2004 02:27:54 +0100
Adrian Bunk <bunk@stusta.de> wrote:

> The patch below contans the following possible cleanups:
> - make some needlessly global code static
> - sch_htb.c: #undef HTB_DEBUG

Applied, thanks Adrian.
