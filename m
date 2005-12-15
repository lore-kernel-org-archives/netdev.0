From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [RFC][PATCH 0/3] TCP/IP Critical socket communication mechanism
Date: Thu, 15 Dec 2005 01:27:05 -0800
Message-ID: <OF91FE0851.3F5D5387-ON882570D8.0031E106-882570D8.0033D677@us.ibm.com>
References: <20051215.005805.114145703.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: ak@suse.de, linux-kernel@vger.kernel.org, mpm@selenic.com,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org,
	shemminger@osdl.org, sri@us.ibm.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1422662AbVLOJ0U@vger.kernel.org>
In-Reply-To: <20051215.005805.114145703.davem@davemloft.net>
To: "David S. Miller" <davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"David S. Miller" <davem@davemloft.net> wrote on 12/15/2005 12:58:05 AM:

> From: David Stevens <dlstevens@us.ibm.com>
> Date: Thu, 15 Dec 2005 00:44:52 -0800
> 
> > In our internal discussions
> 
> I really wish this hadn't been discussed internally before being
> implemented.  Any such internal discussions are lost completely upon
> the community that ends up reviewing such a core and invasive patch
> such as this one.

I think those were more informal and less extensive than the
impression I gave you. I mean simply bouncing around incomplete
ideas and discussing some of the potential issues before coming
up with a prototype solution, which is intended to be the starting
point for community discussions (and the KS discussions, too). "OOM"
came up immediately (even when naming the problem), and it isn't how
I ever saw it.

The patches, of course, are intended to NOT be invasive, or any
more than they need to be, and they are not "the" solution, but
"a" solution. A completely different one that solves the problem
is just as good to me.

                                                        +-DLS
