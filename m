From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [Routing] Performance Comparison between 2.6 and 2.4 kernel
Date: Wed, 15 Sep 2004 11:08:58 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040915110858.125cea28.davem@davemloft.net>
References: <1094868693.1041.86.camel@jzny.localdomain>
	<20040915180603.98079.qmail@web40007.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Song Wang <wsonguci@yahoo.com>
In-Reply-To: <20040915180603.98079.qmail@web40007.mail.yahoo.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 15 Sep 2004 11:06:03 -0700 (PDT)
Song Wang <wsonguci@yahoo.com> wrote:

> The mips CPU on the board is MIPS32 compatible.
> I don't think it's NAPI based.

NAPI is an attribute of the network adapter, not
the cpu.

Although I would very much anticipate this being
a MIPS or network adapter specific problem since
on x86 routing is pretty fast in 2.6.x
