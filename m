From: Marco Mellia <mellia@prezzemolo.polito.it>
Subject: Re: [E1000-devel] Transmission limit
Date: 30 Nov 2004 09:42:26 +0100
Message-ID: <1101804146.11111.23.camel@mellia.lipar.polito.it>
References: <1101467291.24742.70.camel@mellia.lipar.polito.it>
	 <41A73826.3000109@draigBrady.com>
	 <1101483081.24742.174.camel@mellia.lipar.polito.it>
	 <20041127092503.GA12592@sunbeam.de.gnumonks.org>
	 <1101718412.14930.46.camel@verza.polito.it>
	 <20041129145028.GC18788@xi.wantstofly.org>
Reply-To: mellia@prezzemolo.polito.it
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Marco Mellia <mellia@prezzemolo.polito.it>,
        Harald Welte <laforge@gnumonks.org>, P@draigBrady.com,
        e1000-devel@lists.sourceforge.net,
        Jorge Manuel Finochietto <jorge.finochietto@polito.it>,
        Giulio Galante <galante@polito.it>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
In-Reply-To: <20041129145028.GC18788@xi.wantstofly.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2004-11-29 at 15:50, Lennert Buytenhek wrote:
> On Mon, Nov 29, 2004 at 09:53:33AM +0100, Marco Mellia wrote:
> 
> > Th's our intuition too.
> > Notice that we get the same results with 3com (broadcom based) gigabit
> > cards.
> > We are thinking of sending packet in "bursts" instead of single
> > transfers. The only problem is to let the NIC know that there are more
> > than a packet in a burst...
> 
> Jamal implemented exactly this for e1000 already, he might be persuaded
> into posting his patch here.  Jamal? :)

I guess that saying that we are _very_ interested in this might help.
:-)
We can offer as "beta-testers" as well...

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
