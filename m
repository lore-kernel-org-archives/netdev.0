From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: 1.03Mpps on e1000 (was: Re: Transmission limit)
Date: Mon, 6 Dec 2004 13:23:00 +0100
Message-ID: <20041206122300.GA12763@xi.wantstofly.org>
References: <1101967983.4782.9.camel@localhost.localdomain> <20041205145051.GA647@xi.wantstofly.org> <Pine.LNX.4.58.0412051559350.29474@tux.rsn.bth.se> <Pine.LNX.4.58.0412051638290.29474@tux.rsn.bth.se> <20041205174401.GJ647@xi.wantstofly.org> <20041205175133.GK647@xi.wantstofly.org> <Pine.LNX.4.58.0412051852340.29474@tux.rsn.bth.se> <1102332757.1042.2255.camel@jzny.localdomain> <20041206121151.GA12598@xi.wantstofly.org> <1102335643.1048.2311.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Martin Josefsson <gandalf@wlug.westbo.se>,
	Scott Feldman <sfeldma@pobox.com>,
	Robert Olsson <Robert.Olsson@data.slu.se>, P@draigBrady.com,
	mellia@prezzemolo.polito.it, e1000-devel@lists.sourceforge.net,
	Jorge Manuel Finochietto <jorge.finochietto@polito.it>,
	Giulio Galante <galante@polito.it>, netdev@oss.sgi.com
Return-path: <e1000-devel-admin@lists.sourceforge.net>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1102335643.1048.2311.camel@jzny.localdomain>
Sender: e1000-devel-admin@lists.sourceforge.net
Errors-To: e1000-devel-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=e1000-devel>
List-Id: netdev.vger.kernel.org

On Mon, Dec 06, 2004 at 07:20:43AM -0500, jamal wrote:

> > > Someone correct me if i am wrong - but does it appear as if all these
> > > changes are only useful on PCI but not PCI-X?
> > 
> > They are useful on PCI-X as well as regular PCI.  On my 64/100 NIC I
> > get ~620kpps on 2.6.9, ~1Mpps with 2.6.9 plus tx rework plus TXDMAC=0.
> > 
> > Martin gets the ~1Mpps number with just the tx rework, and even more
> > with TXDMAC=0 added in as well.
> 
> Right, but so far when i scan the results all i see is PCI not PCI-X.
> Which of your (or Martins) boards has PCI-X?

I've tested 32/33 PCI, 32/66 PCI, and 64/100 PCI-X.  I _think_ Martin
was running at 64/133 PCI-X.


--L


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
