From: "David S. Miller" <davem@redhat.com>
Subject: Re: 2.6: net/core.c should export sysctl_optmem_max for modular
 IPV6
Date: Thu, 26 Feb 2004 12:14:15 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040226121415.4836150a.davem@redhat.com>
References: <20040226015907.GA10986@merlin.emma.line.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Matthias Andree <matthias.andree@gmx.de>
In-Reply-To: <20040226015907.GA10986@merlin.emma.line.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 26 Feb 2004 02:59:07 +0100
Matthias Andree <matthias.andree@gmx.de> wrote:

> IPv6 built as a module fails (in 2.6 BitKeeper tree) because it cannot
> link to sysctl_optmem_max, trivial patch:

Applied, thanks Matthias.
(2.4.x is going to need this too so I added your change there too)
