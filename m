From: Andre Hedrick <andre@linux-ide.org>
Subject: Re: [Design] [PATCH] USAGI IPsec
Date: Sun, 20 Oct 2002 21:22:23 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.10.10210202120100.674-100000@master.linux-ide.org>
References: <3DB41338.3070502@storm.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mitsuru KANDA <mk@linux-ipv6.org>, linux-kernel@vger.kernel.org,
   netdev@oss.sgi.com, cryptoapi-devel@kerneli.org, design@lists.freeswan.org,
   usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Sandy Harris <sandy@storm.ca>
In-Reply-To: <3DB41338.3070502@storm.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


It is all bolted togather and does not need to be piece from random parts.
Thus in simple reality, it is superior.

Maybe FreeS/WAN will get busy and compete or die.

Cheers,

Andre Hedrick
LAD Storage Consulting Group

On Mon, 21 Oct 2002, Sandy Harris wrote:

> Mitsuru KANDA wrote:
> 
> >Hello Linux kernel network maintainers,
> >
> >I'm a member of USAGI project.
> >
> >In IPv6 specifications, IPsec is mandatory.
> >
> >We implemented IPsec for Linux IP stack.
> >
> >At present, our implementation includes:
> >	PF_KEY V2 interface,
> >	Security Association Database and
> >	Security Policy Database for whole IP versions,
> >	IPsec for IPv6,(transport, tunnel mode),
> >	IPsec for IPv4 (transport mode),
> >
> >Would you mind checking it ?
> >
> Is this code being checked in to the mainline kernel? Or becoming part 
> of the
> CryptoAPI patch set? Bravo, in either case.
> 
> How does that affect FreeS/WAN development?
> 
> >  
> >
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 
