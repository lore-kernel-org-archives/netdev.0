From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] (4/6) ipvs -- use reader locks and refcounts correctly.
Date: Sun, 21 Sep 2003 17:53:58 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030921175358.329774aa.davem@redhat.com>
References: <20030920010010.7ed69543.davem@redhat.com>
	<Pine.LNX.4.44.0309202338250.2193-200000@penguin.linux-vs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, lvs-users@LinuxVirtualServer.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Wensong Zhang <wensong@linux-vs.org>
In-Reply-To: <Pine.LNX.4.44.0309202338250.2193-200000@penguin.linux-vs.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 20 Sep 2003 23:39:10 +0800 (CST)
Wensong Zhang <wensong@linux-vs.org> wrote:

> On Sat, 20 Sep 2003, David S. Miller wrote:
> 
> > On Thu, 18 Sep 2003 00:44:16 +0800 (CST)
> > Wensong Zhang <wensong@linux-vs.org> wrote:
> > 
> > > So, maybe we just apply the simple patch with making the lock local and 
> > > tagging user pointers.
> > 
> > Can someone put such a patch together for me?
> > 
> 
> Please see the attached patch.

Applied, thanks Wensong.
