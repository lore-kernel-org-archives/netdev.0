From: jamal <hadi@cyberus.ca>
Subject: Re: 1.03Mpps on e1000 (was: Re: Transmission limit)
Date: 06 Dec 2004 08:11:02 -0500
Message-ID: <1102338662.1042.2365.camel@jzny.localdomain>
References: <1101967983.4782.9.camel@localhost.localdomain>
	 <20041205145051.GA647@xi.wantstofly.org>
	 <Pine.LNX.4.58.0412051559350.29474@tux.rsn.bth.se>
	 <Pine.LNX.4.58.0412051638290.29474@tux.rsn.bth.se>
	 <20041205174401.GJ647@xi.wantstofly.org>
	 <20041205175133.GK647@xi.wantstofly.org>
	 <Pine.LNX.4.58.0412051852340.29474@tux.rsn.bth.se>
	 <1102332757.1042.2255.camel@jzny.localdomain>
	 <20041206121151.GA12598@xi.wantstofly.org>
	 <1102335643.1048.2311.camel@jzny.localdomain>
	 <20041206122300.GA12763@xi.wantstofly.org>
	 <Pine.LNX.4.58.0412061329290.32624@tux.rsn.bth.se>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Lennert Buytenhek <buytenh@wantstofly.org>, Scott Feldman <sfeldma@pobox.com>, Robert Olsson <Robert.Olsson@data.slu.se>,  P@draigBrady.com, mellia@prezzemolo.polito.it, e1000-devel@lists.sourceforge.net,  Jorge Manuel Finochietto <jorge.finochietto@polito.it>, Giulio Galante <galante@polito.it>, netdev@oss.sgi.com
Return-path: <e1000-devel-admin@lists.sourceforge.net>
To: Martin Josefsson <gandalf@wlug.westbo.se>
In-Reply-To: <Pine.LNX.4.58.0412061329290.32624@tux.rsn.bth.se>
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

Hopefully someone will beat me to testing to see if our forwarding
capacity now goes up with this new recipe.

cheers,
jamal

On Mon, 2004-12-06 at 07:30, Martin Josefsson wrote:
> On Mon, 6 Dec 2004, Lennert Buytenhek wrote:
> 
> > > Right, but so far when i scan the results all i see is PCI not PCI-X.
> > > Which of your (or Martins) boards has PCI-X?
> >
> > I've tested 32/33 PCI, 32/66 PCI, and 64/100 PCI-X.  I _think_ Martin
> > was running at 64/133 PCI-X.
> 
> I don't have any motherboards with PCI-X so no :)
> I'm running the 82546GB (dualport) at 64/66 and the 82540EM (desktop
> adapter) at 32/66, both are able to send at wirespeed.
> 
> /Martin
> 
> 



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
