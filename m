From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [E1000-devel] Transmission limit
Date: Mon, 29 Nov 2004 15:50:28 +0100
Message-ID: <20041129145028.GC18788@xi.wantstofly.org>
References: <1101467291.24742.70.camel@mellia.lipar.polito.it> <41A73826.3000109@draigBrady.com> <1101483081.24742.174.camel@mellia.lipar.polito.it> <20041127092503.GA12592@sunbeam.de.gnumonks.org> <1101718412.14930.46.camel@verza.polito.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Harald Welte <laforge@gnumonks.org>, P@draigBrady.com,
        e1000-devel@lists.sourceforge.net,
        Jorge Manuel Finochietto <jorge.finochietto@polito.it>,
        Giulio Galante <galante@polito.it>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Marco Mellia <mellia@prezzemolo.polito.it>
Content-Disposition: inline
In-Reply-To: <1101718412.14930.46.camel@verza.polito.it>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Nov 29, 2004 at 09:53:33AM +0100, Marco Mellia wrote:

> Th's our intuition too.
> Notice that we get the same results with 3com (broadcom based) gigabit
> cards.
> We are thinking of sending packet in "bursts" instead of single
> transfers. The only problem is to let the NIC know that there are more
> than a packet in a burst...

Jamal implemented exactly this for e1000 already, he might be persuaded
into posting his patch here.  Jamal? :)


--L
