From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [RFC] TCP congestion infrastructure
Date: Tue, 10 May 2005 09:13:09 -0700
Message-ID: <20050510091309.3d887c73@dxpl.pdx.osdl.net>
References: <20050506173729.20140.93205.37072@galon.ev-en.org>
	<20050509162214.0a8c9ceb@dxpl.pdx.osdl.net>
	<20050509.171711.75189002.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: baruch@ev-en.org, netdev@oss.sgi.com, doug.leith@nuim.ie
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050509.171711.75189002.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 09 May 2005 17:17:11 -0700 (PDT)
"David S. Miller" <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@osdl.org>
> Subject: [RFC] TCP congestion infrastructure
> Date: Mon, 9 May 2005 16:22:14 -0700
> 
> > I rebased the H-TCP patches on my current work and 2.6.12-rc4 and put them in
> > 	http://developer.osdl.org/shemminger/patches/2.6.12-rc4-tcp/
> > 
> > Includes infrastructure and all the current variants: BIC, Westwood, Vegas
> >     plus  H-TCP, Hybla
> 
> I like it.  Looks fine from here.
> 
> This, along with the TSO reworking, will go in at the next
> opportunity which is likely 2.6.13 of course.
> 
> I'm considering putting the TSO stuff into 2.6.12 because
> in many ways it is a bug fix, TSO is fairly broken without
> it.  There are some loose ends I need to resolve first though.

I'll put tso-reloaded in next set (2.6.12-rc4-tcp2) so if you have a better
version send me it.
