From: "David S. Miller" <davem@redhat.com>
Subject: Re: SCTP sockopt discrepancy between 2.4 and 2.6.
Date: Mon, 2 Feb 2004 11:03:40 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040202110340.3f4cdabd.davem@redhat.com>
References: <1075747382.786.366.camel@hades.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, marcelo.tosatti@cyclades.com,
        lksctp-developers@lists.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: David Woodhouse <dwmw2@infradead.org>
In-Reply-To: <1075747382.786.366.camel@hades.cambridge.redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 02 Feb 2004 18:43:03 +0000
David Woodhouse <dwmw2@infradead.org> wrote:

> Am I missing something -- like perhaps the existence of a patch to
> update the 2.4 kernel -- or is the SCTP implementation in 2.4 no longer
> being maintained, and no longer compatible with 2.6 and its userspace?

Good catch David, this does need to be synchronized and fixed.

I believe the 2.4.x SCTP code was a port of some older 2.6.x incantation
and then the 2.6.x line kept being updated yet such updates never were
merged 2.4.x'ward.
