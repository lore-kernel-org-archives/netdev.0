From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: Kernel 2.6 IPV6 Busted
Date: Wed, 02 Mar 2005 14:12:40 -0500
Message-ID: <42261028.7030301@pobox.com>
References: <200502270928.44402.Info@Quantum-Sci.com> <200503011207.34029.vda@port.imtp.ilyichevsk.odessa.ua> <422497BA.9090606@pobox.com> <200503021602.53663.vda@port.imtp.ilyichevsk.odessa.ua>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Quantum Scientific <Info@quantum-sci.com>, netdev@oss.sgi.com
To: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
In-Reply-To: <200503021602.53663.vda@port.imtp.ilyichevsk.odessa.ua>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Denis Vlasenko wrote:
> On Tuesday 01 March 2005 18:26, Jeff Garzik wrote:
> 
>>>>There are many very important optimizations we've had to disable
>>>>by default just in TCP alone because of NAT.
>>>
>>>I don't think future Internet will be safe enough to open
>>>corporate networks. I definitely won't do it.
>>>NAT firewall in front of my net is an absolute requirement
>>>for me.
>>>
>>>However, IPv6 in Internet won't happen tomorrow,
>>>no rush...
>>
>>You don't need NAT to secure a corporate network.
> 
> 
> I don't want outside world to even KNOW that I have a network
> behind the firewall box. I don't want them to know
> internal hosts' IPs.

  ...thus breaking the end-to-end connection model, and various protocols.

	Jeff
