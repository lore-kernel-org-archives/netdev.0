From: Marco Mellia <mellia@prezzemolo.polito.it>
Subject: Re: [E1000-devel] Transmission limit
Date: 02 Dec 2004 14:39:32 +0100
Message-ID: <1101994772.18491.16.camel@mellia.lipar.polito.it>
References: <1101467291.24742.70.camel@mellia.lipar.polito.it>
	 <41A73826.3000109@draigBrady.com>
	 <1101483081.24742.174.camel@mellia.lipar.polito.it>
	 <20041127092503.GA12592@sunbeam.de.gnumonks.org>
	 <1101718412.14930.46.camel@verza.polito.it>
	 <20041129145028.GC18788@xi.wantstofly.org>
	 <1101804146.11111.23.camel@mellia.lipar.polito.it>
	 <1101903944.1042.29.camel@jzny.localdomain>
Reply-To: mellia@prezzemolo.polito.it
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: mellia@prezzemolo.polito.it, Lennert Buytenhek <buytenh@wantstofly.org>,
        Harald Welte <laforge@gnumonks.org>, P@draigBrady.com,
        e1000-devel@lists.sourceforge.net,
        Jorge Manuel Finochietto <jorge.finochietto@polito.it>,
        Giulio Galante <galante@polito.it>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1101903944.1042.29.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> > > > We are thinking of sending packet in "bursts" instead of single
> > > > transfers. The only problem is to let the NIC know that there are more
> > > > than a packet in a burst...
> > > 
> > > Jamal implemented exactly this for e1000 already, he might be persuaded
> > > into posting his patch here.  Jamal? :)
> > 
> > I guess that saying that we are _very_ interested in this might help.
> > :-)
> > We can offer as "beta-testers" as well...
> 
> Sorry missed this (I wasnt CCed so it went to a low priority queue which
> i read on a best effort basis).
> Let me clean up the patches a little bit this weekend. The patch is at
> least 4 months old; latest reincarnation was due to issue1 on my SUCON
> presentation. Would a patch against latest 2.6.x bitkeeper (whatever it
> is this weekend) be fine? If you are in a rush and dont mind a little
> ugliness then i will pass them as is.
> 
We'll be glad to spend some time trying this out. Please, we are not
very confortable with the linux bitkeeper maintenance method. Can we ask
you to provide us a patch to a standard kernel/driver (whatever you
prefer...)? Also a complete source sub-tree would be ok ;-)

> BTW, Scott posted a interesting patch yesterday, you may wanna give that
> a shot as well. 

We're trying that out right now... (which means, that in a couple of
days, we'll try it ;-))

Thanks a lot.

-- 
Ciao,                    /\/\/\rco

+-----------------------------------+  
| Marco Mellia - Assistant Professor|
| Tel: 39-011-2276-608              |
| Tel: 39-011-564-4173              |
| Cel: 39-340-9674888               |   /"\  .. . . . . . . . . . . . .
| Politecnico di Torino             |   \ /  . ASCII Ribbon Campaign  .
| Corso Duca degli Abruzzi 24       |    X   .- NO HTML/RTF in e-mail .
| Torino - 10129 - Italy            |   / \  .- NO Word docs in e-mail.
| http://www1.tlc.polito.it/mellia  |        .. . . . . . . . . . . . .
+-----------------------------------+
The box said "Requires Windows 95 or Better." So I installed Linux.
