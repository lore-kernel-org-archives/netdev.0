From: "David S. Miller" <davem@redhat.com>
Subject: Re: [2.6 PATCH] ipvs - properly handle non-linear skbs
Date: Sun, 5 Oct 2003 05:19:13 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031005051913.0df50683.davem@redhat.com>
References: <Pine.LNX.4.44.0310051151430.1204-101000@u.domain.uli>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: rusty@rustcorp.com.au, wensong@linux-vs.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Julian Anastasov <ja@ssi.bg>
In-Reply-To: <Pine.LNX.4.44.0310051151430.1204-101000@u.domain.uli>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 5 Oct 2003 12:09:20 +0300 (EEST)
Julian Anastasov <ja@ssi.bg> wrote:

> 	Attached is a patch that includes the changes from
> Rusty about handling non-linear skbs correctly and modified
> a bit from Wensong Zhang and me.

Patch applied, thanks to everyone for following through on
this work.
