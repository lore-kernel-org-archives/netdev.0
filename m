From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC] netem - add jitter support.
Date: 12 Jul 2004 22:39:36 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1089686376.1044.24.camel@jzny.localdomain>
References: <20040708135320.03366bd7@dell_ss3.pdx.osdl.net>
	 <1089335650.1046.150.camel@jzny.localdomain>
	 <20040712081239.21697179@dell_ss3.pdx.osdl.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040712081239.21697179@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2004-07-12 at 11:12, Stephen Hemminger wrote:

> > - Could that table be computed in user space instead? This way you are
> > not restricted to just the normal distribution. I could also use them
> > if available from within tc sources,
> 
> That wouldn't be hard, maybe even the ability to do correlated distributions.

Exactly - i have a standard action which is currently programmable for
randomization as well; so if you have a standard way to send from user
space(tc) i will use it. Actually those tables are well done in NIST. I
am suprised i missed them before now. 

cheers,
jamal
