From: jamal <hadi@cyberus.ca>
Subject: Re: Network card driver problem (znb.o/tulip)
Date: 20 Mar 2005 14:09:51 -0500
Message-ID: <1111345791.1095.86.camel@jzny.localdomain>
References: <efe3b00605031021513b7268d1@mail.gmail.com>
	 <200503182333.51470.jdmason@us.ibm.com>
	 <efe3b0060503190229dff2a01@mail.gmail.com>
	 <200503190757.27727.jdmason@us.ibm.com>
	 <20050319152354.GA4946@electric-eye.fr.zoreil.com>
	 <1111327546.1094.47.camel@jzny.localdomain>
	 <efe3b006050320110226b2dba1@mail.gmail.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, Jon Mason <jdmason@us.ibm.com>,
        Ben Greear <greearb@candelatech.com>, jgarzik@pobox.com,
        tulip-users@lists.sourceforge.net, netdev@oss.sgi.com
To: Kosta Todorovic <kostodo@gmail.com>
In-Reply-To: <efe3b006050320110226b2dba1@mail.gmail.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


I dont think mii-tool will tell you the truth with these cards.
Like i was saying earlier - they use SYM PHYs.
 
Does it work on 32 bit machines? I am assuming when you say "64 bit" you
mean the architecture not PCI bus.

cheers,
jamal

On Sun, 2005-03-20 at 14:02, Kosta Todorovic wrote:
> Using the standard tulip driver in 64bit mode loads the cards but they
> just dont seem to work.
> When i tested with "mii-tool -w" it keep saying "Autonegotiation Failed".
