From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Iproute2: update
Date: Mon, 17 Jan 2005 20:39:17 +0100
Message-ID: <20050117193917.GF26856@postel.suug.ch>
References: <20050112125903.64d42737@dxpl.pdx.osdl.net> <1105895352.1091.705.camel@jzny.localdomain> <1105897532.1097.749.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jamal Hadi Salim <hadi@znyx.com>
Content-Disposition: inline
In-Reply-To: <1105897532.1097.749.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Jamal Hadi Salim <1105897532.1097.749.camel@jzny.localdomain> 2005-01-16 12:45
> On Sun, 2005-01-16 at 12:09, jamal wrote:
> > Here's one fix
> > 
> 
> And another one from before that is missing from the current version.
> Also something for the makefile - You may be unhappy with the way the
> IPT_INCL is defined in the makefile.
> Feel free to move it to configure etc or even kill it if it works
> without it.

It seems that ipt code is still missing in stephen's bk tree so the
patch doesn't apply cleanly. It's no problem to fix it but you
might to provide the patch again.

Stephen, I can put it into my bk tree and you can pull it together
with my my changes if you want.
