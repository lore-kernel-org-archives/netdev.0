From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: The ultimate TOE design
Date: Thu, 16 Sep 2004 13:19:21 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1095337159.22739.7.camel@localhost.localdomain>
References: <20040915141346.5c5e5377.davem@davemloft.net>
	 <4148991B.9050200@pobox.com>
	 <Pine.LNX.4.61.0409152102050.23011@fogarty.jakma.org>
	 <1095275660.20569.0.camel@localhost.localdomain> <4148A90F.80003@pobox.com>
	 <20040915140123.14185ede.davem@davemloft.net>
	 <20040915210818.GA22649@havoc.gtf.org>
	 <20040915141346.5c5e5377.davem@davemloft.net>
	 <5.1.0.14.2.20040916192213.04240008@171.71.163.14>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, "David S. Miller" <davem@davemloft.net>,
        paul@clubi.ie, netdev@oss.sgi.com, leonid.grossman@s2io.com,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Lincoln Dale <ltd@cisco.com>
In-Reply-To: <5.1.0.14.2.20040916192213.04240008@171.71.163.14>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Iau, 2004-09-16 at 10:29, Lincoln Dale wrote:
> . . . this ignore the realities of power restrictions of PCI today . . .
> sure, one could create a PCI card that takes a power-connector, but that 
> don't scale so well either . . .

At 1Ghz the Athlon Geode NX draws about 6W. Thats less than my SCSI
controller. I'm sure its not co-incidence that powerpc shows up on such
boards a lot more than x86 however.
