From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] (4/6) ipvs -- use reader locks and refcounts correctly.
Date: Sat, 20 Sep 2003 01:00:10 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030920010010.7ed69543.davem@redhat.com>
References: <20030916142116.58a05005.shemminger@osdl.org>
	<Pine.LNX.4.44.0309180014470.15676-200000@penguin.linux-vs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, lvs-users@LinuxVirtualServer.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Wensong Zhang <wensong@linux-vs.org>
In-Reply-To: <Pine.LNX.4.44.0309180014470.15676-200000@penguin.linux-vs.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 18 Sep 2003 00:44:16 +0800 (CST)
Wensong Zhang <wensong@linux-vs.org> wrote:

> So, maybe we just apply the simple patch with making the lock local and 
> tagging user pointers.

Can someone put such a patch together for me?

Thanks.
