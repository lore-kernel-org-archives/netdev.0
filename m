From: jamal <hadi@cyberus.ca>
Subject: Re: Do you know the TCP stack? (127.x.x.x routing)
Date: 08 Mar 2005 08:58:20 -0500
Message-ID: <1110290300.1050.190.camel@jzny.localdomain>
References: <E1D7lQN-0002gz-00@smtp06.mrf.mail.rcn.net>
	 <E1D7lQN-0002gz-00@smtp06.mrf.mail.rcn.net>
	 <E1D7zBN-0004hX-00@smtp02.mrf.mail.rcn.net>
	 <20050306173145.GQ31837@postel.suug.ch>
	 <E1D81mg-0002rz-00@smtp01.mrf.mail.rcn.net> <m1y8d0mss2.fsf@muc.de>
	 <3sp35g$7hpm0@smtp04.mrf.mail.rcn.net> <422C0B50.20500@mrv.com>
	 <3sp35g$7rsc1@smtp04.mrf.mail.rcn.net>
	 <1110288879.1050.167.camel@jzny.localdomain>
	 <20050308135134.GA20607@atrey.karlin.mff.cuni.cz>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Zdenek Radouch <zdenek@rcn.com>,
	Steve Iribarne <steve.iribarne@dilithiumnetworks.com>,
	Eran Mann <emann@mrv.com>, Thomas Graf <tgraf@suug.ch>,
	Andi Kleen <ak@muc.de>, netdev@oss.sgi.com,
	linux-net@vger.kernel.org
To: Martin Mares <mj@ucw.cz>
In-Reply-To: <20050308135134.GA20607@atrey.karlin.mff.cuni.cz>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2005-03-08 at 08:51, Martin Mares wrote:
> Hello!
> 
> > Seems to me you are relying on obscurity of 127.x to achieve goals which
> > you could achieve just as easily with a 10.x address or even a public
> > address.
> 
> Using the same public block in all devices looks like the best solution.
> 

People tend to use private blocks in a chasis (unique IP for each blade)
- which by default are not routed outside the chasis.

I have a feeling this is what you meant

cheers,
jamal

