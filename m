From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 1/5] r8169: auto detect 32-bit slot
Date: Wed, 9 Mar 2005 13:55:30 -0800
Message-ID: <20050309135530.5c5c80b6@dxpl.pdx.osdl.net>
References: <20050309112925.7f7900ab@dxpl.pdx.osdl.net>
	<m17jkgwp6i.fsf@muc.de>
	<20050309214023.GA9502@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <ak@muc.de>, netdev@oss.sgi.com
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20050309214023.GA9502@electric-eye.fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 9 Mar 2005 22:40:23 +0100
Francois Romieu <romieu@fr.zoreil.com> wrote:

> Andi Kleen <ak@muc.de> :
> [...]
> > Hmm? It doesn't support DAC? 
> 
> It does but it is unstable for everybody (except Jon Mason, go figure) on
> amd64.
> 
> Stephen, on which kind of system was this change tested ?

I tested on old Celeron with Netgear card.  I could try Amd and/or Xeon
if you want.
