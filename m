From: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
Subject: Re: Kernel 2.6 IPV6 Busted
Date: Wed, 2 Mar 2005 16:02:53 +0200
Message-ID: <200503021602.53663.vda@port.imtp.ilyichevsk.odessa.ua>
References: <200502270928.44402.Info@Quantum-Sci.com> <200503011207.34029.vda@port.imtp.ilyichevsk.odessa.ua> <422497BA.9090606@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="koi8-r"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Quantum Scientific <Info@quantum-sci.com>, netdev@oss.sgi.com
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <422497BA.9090606@pobox.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tuesday 01 March 2005 18:26, Jeff Garzik wrote:
> >>There are many very important optimizations we've had to disable
> >>by default just in TCP alone because of NAT.
> > 
> > I don't think future Internet will be safe enough to open
> > corporate networks. I definitely won't do it.
> > NAT firewall in front of my net is an absolute requirement
> > for me.
> > 
> > However, IPv6 in Internet won't happen tomorrow,
> > no rush...
> 
> You don't need NAT to secure a corporate network.

I don't want outside world to even KNOW that I have a network
behind the firewall box. I don't want them to know
internal hosts' IPs.
--
vda
