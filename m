From: Sandy Harris <sandy@storm.ca>
Subject: Re: [Design] [PATCH] USAGI IPsec
Date: Mon, 21 Oct 2002 07:46:16 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DB41338.3070502@storm.ca>
References: <m3k7kpjt7c.wl@karaba.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
   cryptoapi-devel@kerneli.org, design@lists.freeswan.org,
   usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Mitsuru KANDA <mk@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Mitsuru KANDA wrote:

>Hello Linux kernel network maintainers,
>
>I'm a member of USAGI project.
>
>In IPv6 specifications, IPsec is mandatory.
>
>We implemented IPsec for Linux IP stack.
>
>At present, our implementation includes:
>	PF_KEY V2 interface,
>	Security Association Database and
>	Security Policy Database for whole IP versions,
>	IPsec for IPv6,(transport, tunnel mode),
>	IPsec for IPv4 (transport mode),
>
>Would you mind checking it ?
>
Is this code being checked in to the mainline kernel? Or becoming part 
of the
CryptoAPI patch set? Bravo, in either case.

How does that affect FreeS/WAN development?

>  
>
