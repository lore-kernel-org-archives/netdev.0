From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: Kernel 2.6 IPV6 Busted
Date: Tue, 01 Mar 2005 11:26:34 -0500
Message-ID: <422497BA.9090606@pobox.com>
References: <200502270928.44402.Info@Quantum-Sci.com> <200502271410.39611.Info@quantum-sci.com> <20050227133517.578884df.davem@davemloft.net> <200503011207.34029.vda@port.imtp.ilyichevsk.odessa.ua>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Quantum Scientific <Info@quantum-sci.com>, netdev@oss.sgi.com
To: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
In-Reply-To: <200503011207.34029.vda@port.imtp.ilyichevsk.odessa.ua>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Denis Vlasenko wrote:
> On Sunday 27 February 2005 23:35, David S. Miller wrote:
> 
>>On Sun, 27 Feb 2005 14:10:39 -0600
>>Quantum Scientific <Info@quantum-sci.com> wrote:
>>
>>
>>>I am skeptical about this assertion that the whole internet needs to be hashed 
>>>if connection tracking.
>>
>>Connection tracking and NAT broke entirely the end-to-end host
>>assumption that used to be valid on the internet.
>>
>>There are many very important optimizations we've had to disable
>>by default just in TCP alone because of NAT.
> 
> 
> I don't think future Internet will be safe enough to open
> corporate networks. I definitely won't do it.
> NAT firewall in front of my net is an absolute requirement
> for me.
> 
> However, IPv6 in Internet won't happen tomorrow,
> no rush...

You don't need NAT to secure a corporate network.

Just write sane firewall rules that don't allow incoming.

	Jeff
