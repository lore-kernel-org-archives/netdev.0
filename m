From: "David S. Miller" <davem@davemloft.net>
Subject: Re: TG3 fix for slow switches (Was: TG3 driver failure on HP
 16-way)
Date: Thu, 6 Jan 2005 21:28:38 -0800
Message-ID: <20050106212838.5e94af1f.davem@davemloft.net>
References: <16839.27239.264551.415058@berry.gelato.unsw.EDU.AU>
	<20041220161552.2b88aa3d.davem@davemloft.net>
	<16839.30796.413939.333935@wombat.chubb.wattle.id.au>
	<20050106151910.4d51673e.davem@davemloft.net>
	<20050107001743.GH17027@cse.unsw.EDU.AU>
	<20050106194838.0909020a.davem@davemloft.net>
	<20050107053009.GI17027@cse.unsw.EDU.AU>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: peterc@gelato.unsw.edu.au, netdev@oss.sgi.com, mchan@broadcom.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Darren Williams <dsw@gelato.unsw.edu.au>
In-Reply-To: <20050107053009.GI17027@cse.unsw.EDU.AU>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 7 Jan 2005 16:30:09 +1100
Darren Williams <dsw@gelato.unsw.edu.au> wrote:

> > In any case, please try this one instead which is a variant
> > of the second patch Peter proposed plus some signedness fixes
> > I've done.
> > 
> No still no link. The patch that I have working is:
> tg3.c:v2.9 (March 8, 2004)
> that I took from 2.6.7

Darren, I believe you are confusing this entire situation.
And I should have suspected this when you were responding
to my test requests instead of Peter.

Peter had a problem on a 16-way HP machine, and the patch
that I just gave to you is nearly identical to his which
he said makes his problem go away.

Are you having the same problem on the same configuration or
are you hoping this fixes some other tg3 bug that you happen
to be seeing?
