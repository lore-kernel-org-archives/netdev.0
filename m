From: Simon Roscic <simon.roscic@chello.at>
Subject: Re: [2.6.0-test8/9] ethertap oops
Date: Mon, 27 Oct 2003 18:40:53 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200310271840.53980.simon.roscic@chello.at>
References: <L1fo.3gb.9@gated-at.bofh.it> <20031026234828.2cb1f746.davem@redhat.com> <20031027122635.GB16013@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@muc.de>, "David S. Miller" <davem@redhat.com>
In-Reply-To: <20031027122635.GB16013@wotan.suse.de>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Monday, 27. Oct 2003 13:26, Andi Kleen wrote:
> On Sun, Oct 26, 2003 at 11:48:28PM -0800, David S. Miller wrote:
> > On Sun, 26 Oct 2003 23:45:52 +0100
> >
> > Andi Kleen <ak@muc.de> wrote:
> > > diff -u linux-2.6.0test7mm1-averell/drivers/net/ethertap.c-o
> > > linux-2.6.0test7mm1-averell/drivers/net/ethertap.c ---
> > > linux-2.6.0test7mm1-averell/drivers/net/ethertap.c-o	2003-09-11
> > > 04:12:33.000000000 +0200 +++
> > > linux-2.6.0test7mm1-averell/drivers/net/ethertap.c	2003-10-26
> > > 23:41:17.000000000 +0100
> >
> > This part looks good, applied.
>
> I don't know if it actually fixed the bug, I did not test it
> (sorry, should have stated that in the original mail)
> But at least it should printk now instead of crashing.
>
> -Andi

Hi Andi,

Your patch fixed the bug!  Thanks a lot!
I applyed the first hunk as David wrote above.

bye,
        simon.
