From: Quantum Scientific <Info@quantum-sci.com>
Subject: Re: Kernel 2.6 IPV6 Busted
Date: Tue, 1 Mar 2005 17:59:53 -0600
Message-ID: <200503011759.53734.Info@quantum-sci.com>
References: <200502270928.44402.Info@Quantum-Sci.com> <200502271220.06560.Info@quantum-sci.com> <4224E3A1.5090003@tomt.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
To: netdev@oss.sgi.com
In-Reply-To: <4224E3A1.5090003@tomt.net>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tuesday 01 March 2005 15:50, Andre Tomt wrote:
> > Remember what my issue is:  
> > - I have a very tight firewall,
> > - I ping6 out,
> > - The firewall blocks the reply back, because the connection is stateless!
> Never, ever, filter ICMP. Or at least be extremely careful doing so. You 
> may end up breaking things like PMTU and error notification mechanisms.

Care to propose some rules?  Maybe not.

 
> Also on a per-system basis I tend to prefer to secure services rather 
> than firewall them; by for example just shutting them off/uninstalling 
> them if not used, binding to localhost, use tcpwrappers.. that sort of 
> thing.

Of course.  This is implicit.  But closing everything is best, to avert investigative activity.

Carl Cook
