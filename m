From: Quantum Scientific <Info@Quantum-Sci.com>
Subject: Re: Kernel 2.6 IPV6 Busted
Date: Tue, 1 Mar 2005 17:55:55 -0600
Message-ID: <200503011755.55671.Info@Quantum-Sci.com>
References: <200502270928.44402.Info@Quantum-Sci.com> <422497BA.9090606@pobox.com> <20050301204615.GC15329@irc.pl>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
To: netdev@oss.sgi.com
In-Reply-To: <20050301204615.GC15329@irc.pl>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tuesday 01 March 2005 14:46, Tomasz Torcz wrote:
> On Tue, Mar 01, 2005 at 11:26:34AM -0500, Jeff Garzik wrote:
> > Just write sane firewall rules that don't allow incoming.
> 
>  Isn't this thread about non-working stateful firewalling? Specifically
> situation where -m state --state RELATED or ESTABLISHED isn't allowin
> any packets because there is no connection tracking? Without allowing
> incoming packets there could be no 2-way communication (for UDP at
> least).

Right.  Nor for any of the other protocols.  No incoming packets.

Carl Cook
