From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [E1000-devel] Transmission limit
Date: Sat, 27 Nov 2004 21:00:30 +0100
Message-ID: <20041127200030.GD27762@xi.wantstofly.org>
References: <1101467291.24742.70.camel@mellia.lipar.polito.it> <41A73826.3000109@draigBrady.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: e1000-devel@lists.sourceforge.net,
        Jorge Manuel Finochietto <jorge.finochietto@polito.it>,
        Giulio Galante <galante@polito.it>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: mellia@prezzemolo.polito.it
Content-Disposition: inline
In-Reply-To: <41A73826.3000109@draigBrady.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Nov 26, 2004 at 02:05:26PM +0000, P@draigBrady.com wrote:

> >What is weird, is that if we artificially "preload" the NIC tx-fifo with
> >packets, and then instruct it to start sending them, those are actually
> >transmitted AT WIRE SPEED!!

I've very interested in exactly what it is you're doing here.  What
do you mean by 'preload'?


--L
