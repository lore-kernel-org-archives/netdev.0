From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] mark CSZ scheduler as broken
Date: Wed, 7 Jul 2004 15:27:22 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040707152722.5660a6f0.davem@redhat.com>
References: <20040707111936.760586b0@dell_ss3.pdx.osdl.net>
	<20040707203245.GA9617@outpost.ds9a.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: bert hubert <ahu@ds9a.nl>
In-Reply-To: <20040707203245.GA9617@outpost.ds9a.nl>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 7 Jul 2004 22:32:45 +0200
bert hubert <ahu@ds9a.nl> wrote:

> On Wed, Jul 07, 2004 at 11:19:36AM -0700, Stephen Hemminger wrote:
> > Since the configuration help for CSZ is broken, and other documentation
> > says it just doesn't work.  Why not mark it as broken to make it obvious?
> 
> For all I care we can zonk it - even Alexey is unclear about its workings or
> use. More of a research project then something we should ship.

Let's do it in 2.7.x, not in 2.6.x
