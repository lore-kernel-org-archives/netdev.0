From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] janitor: sched_timeout() sets curr_state (net/)
Date: Tue, 7 Oct 2003 07:45:53 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031007074553.1385f5f1.davem@redhat.com>
References: <20031005203906.2eadaac4.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Randy.Dunlap" <rddunlap@osdl.org>
In-Reply-To: <20031005203906.2eadaac4.rddunlap@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 5 Oct 2003 20:39:06 -0700
"Randy.Dunlap" <rddunlap@osdl.org> wrote:

> From: Alexey Dobriyan <adobriyan@mail.ru>
> 
>  linux-260-test6-kj1-rddunlap/net/atm/resources.c        |    1 -
>  linux-260-test6-kj1-rddunlap/net/bluetooth/hci_core.c   |    1 -
>  linux-260-test6-kj1-rddunlap/net/ipv4/ipvs/ip_vs_sync.c |    2 --
>  linux-260-test6-kj1-rddunlap/net/sunrpc/svcsock.c       |    1 -
>  4 files changed, 5 deletions(-)

Applied, thanks Randy.
