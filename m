From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCHES] IPVS - use list_for_each_entry_continue, fix NQ
Date: Tue, 30 Sep 2003 01:56:59 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030930015659.3cc375b1.davem@redhat.com>
References: <Pine.LNX.4.44.0309271447470.2845-500000@u.domain.uli>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: wensong@linux-vs.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Julian Anastasov <ja@ssi.bg>
In-Reply-To: <Pine.LNX.4.44.0309271447470.2845-500000@u.domain.uli>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 27 Sep 2003 15:02:57 +0300 (EEST)
Julian Anastasov <ja@ssi.bg> wrote:

> 	The attached patches against today's 2.6 BK tree introduce 
> list_for_each_entry_continue and use it for some IPVS schedulers. There is 
> also a NQ scheduler fix. Please consider for inclusion.

Looks good, applied.  Can you please CC: netdev@oss.sgi.com on all
patch submissions, even small and obvious ones?  Thanks.

I assume you guys are still reviewing Rusty's skb_linearize()
removal patch?
