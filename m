From: "David S. Miller" <davem@redhat.com>
Subject: Re: tunnel xmit and h.raw
Date: Fri, 3 Oct 2003 07:30:39 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031003073039.7ca1a76c.davem@redhat.com>
References: <Pine.LNX.4.44.0310030252070.1394-100000@u.domain.uli>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Julian Anastasov <ja@ssi.bg>
In-Reply-To: <Pine.LNX.4.44.0310030252070.1394-100000@u.domain.uli>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 3 Oct 2003 03:00:27 +0300 (EEST)
Julian Anastasov <ja@ssi.bg> wrote:

> 	Is the following change needed? May be yes for all kernels
> where the nearest skb_shared checks are actual.

There seems to be no end to these kinds of bugs in the tunnel
drivers!

Didn't we fix a nearly identical set of bugs in the tunnel
drivers just a month or two ago?

I'll review this some more tomorrow and unless I find some problem
I'll apply your patch.  Thanks a lot.
