From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: Iproute2: update
Date: Mon, 17 Jan 2005 14:24:13 -0800
Message-ID: <20050117142413.3ef1fb63@dxpl.pdx.osdl.net>
References: <20050112125903.64d42737@dxpl.pdx.osdl.net>
	<1105895352.1091.705.camel@jzny.localdomain>
	<1105897532.1097.749.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@znyx.com
In-Reply-To: <1105897532.1097.749.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 16 Jan 2005 12:45:32 -0500
Jamal Hadi Salim <hadi@znyx.com> wrote:

> On Sun, 2005-01-16 at 12:09, jamal wrote:
> > Here's one fix
> > 
> 
> And another one from before that is missing from the current version.
> Also something for the makefile - You may be unhappy with the way the
> IPT_INCL is defined in the makefile.

Yup, I am not going to let the in. I put the iptables headers
needed in include.

> Feel free to move it to configure etc or even kill it if it works
> without it.
> 
> cheers,
> jamal


-- 
Stephen Hemminger	<shemminger@osdl.org>
