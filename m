From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: Re: [PATCH] Add nl_open to libnetlink
Date: Fri, 9 Jul 2004 12:51:00 +0900
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040709125100.3edce4e9@localhost>
References: <20040703094632.GA14235@gondor.apana.org.au>
	<20040705160500.208591b5@localhost>
	<20040706140550.2d483dc8@dell_ss3.pdx.osdl.net>
	<20040707130950.0112edf6@localhost>
	<20040707140533.41c66c03@localhost>
	<20040707155602.4698121a@localhost>
	<20040707110315.GA26100@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040707110315.GA26100@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Herbert,

Thanks for comments.

On Wed, 7 Jul 2004 21:03:15 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Could you please change the output of ip xfrm policy/state so that
> it can be fed directly back in? For example the output of ip ro ls
> can be fed back into ip ro add.

Yes. I'll fix the output to follow current command line option.

> Could you please also make it understand ip x p instead of ip x policy?

Sure.

> And there seems to be something wrong with the keys in the output of
> ip x state.  There are too many f's for it to be right.

OK. I'll check it.


-- 
Masahide NAKAMURA
