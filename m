From: "David S. Miller" <davem@redhat.com>
Subject: Re: [2.4 PATCH] Fix IPVS ftp to use cp->vaddr
Date: Fri, 17 Oct 2003 23:41:25 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031017234125.457d8ae9.davem@redhat.com>
References: <Pine.LNX.4.44.0310181357140.6525-200000@penguin.linux-vs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, ja@ssi.bg
Return-path: <netdev-bounce@oss.sgi.com>
To: Wensong Zhang <wensong@linux-vs.org>
In-Reply-To: <Pine.LNX.4.44.0310181357140.6525-200000@penguin.linux-vs.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 18 Oct 2003 14:24:11 +0800 (CST)
Wensong Zhang <wensong@linux-vs.org> wrote:

> Here is a minor patch for IPVS in the kernel 2.4. It is to fix ip_vs_ftp 
> to use cp->vaddr because iph->daddr is already mangled before calling 
> ip_vs_ftp_in.
> 
> Please check and apply it.

Patch applied, thank you Wensong.
