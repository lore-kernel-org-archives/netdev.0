From: Quantum Scientific <Info@quantum-sci.com>
Subject: Re: Kernel 2.6 IPV6 Busted
Date: Tue, 1 Mar 2005 07:50:00 -0600
Message-ID: <200503010750.00630.Info@quantum-sci.com>
References: <200502270928.44402.Info@Quantum-Sci.com> <20050227133517.578884df.davem@davemloft.net> <200503011207.34029.vda@port.imtp.ilyichevsk.odessa.ua>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="koi8-r"
Content-Transfer-Encoding: 7bit
To: netdev@oss.sgi.com
In-Reply-To: <200503011207.34029.vda@port.imtp.ilyichevsk.odessa.ua>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tuesday 01 March 2005 4:07, Denis Vlasenko wrote:
> I don't think future Internet will be safe enough to open
> corporate networks. I definitely won't do it.
> NAT firewall in front of my net is an absolute requirement
> for me.

I agree that security is an absolute must.  It's irresponsible to contend 
otherwise.

But black-box NAT is just *simulating* what a well-made ip6tables firewall 
does much better.  There's no reason every node can't be secure, except the 
expertise of the script designer.  This is why I wish Shorewall would support 
IPV6.

Carl Cook
