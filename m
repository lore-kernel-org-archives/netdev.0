From: Kosta Todorovic <kostodo@gmail.com>
Subject: Re: Network card driver problem (znb.o/tulip)
Date: Sun, 20 Mar 2005 23:18:14 +0400
Message-ID: <efe3b006050320111879022bc2@mail.gmail.com>
References: <efe3b00605031021513b7268d1@mail.gmail.com>
	 <200503182333.51470.jdmason@us.ibm.com>
	 <efe3b0060503190229dff2a01@mail.gmail.com>
	 <200503190757.27727.jdmason@us.ibm.com>
	 <20050319152354.GA4946@electric-eye.fr.zoreil.com>
	 <1111327546.1094.47.camel@jzny.localdomain>
	 <efe3b006050320110226b2dba1@mail.gmail.com>
	 <1111345791.1095.86.camel@jzny.localdomain>
Reply-To: Kosta Todorovic <kostodo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, Jon Mason <jdmason@us.ibm.com>,
        Ben Greear <greearb@candelatech.com>, jgarzik@pobox.com,
        tulip-users@lists.sourceforge.net, netdev@oss.sgi.com
To: hadi@cyberus.ca
In-Reply-To: <1111345791.1095.86.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> I dont think mii-tool will tell you the truth with these cards.
> Like i was saying earlier - they use SYM PHYs.

Either way, no traffic moved across them when I tried.


> Does it work on 32 bit machines? I am assuming when you say "64 bit" you
> mean the architecture not PCI bus.

Yes it does work on 32bit machines, but with the actual znb.o driver
thats supplied by ZNXY.
And yes i am refering to architecture and NOT pci bus.
