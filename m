From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] remove unused netlink NL_EMULATE_DEV code
Date: 18 Mar 2005 20:48:20 -0500
Message-ID: <1111196899.1264.118.camel@jzny.localdomain>
References: <20050318233637.GS5389@shell0.pdx.osdl.net>
	 <423B6DAE.9050803@qualcomm.com> <20050319010253.GU5389@shell0.pdx.osdl.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Max Krasnyansky <maxk@qualcomm.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
To: Chris Wright <chrisw@osdl.org>
In-Reply-To: <20050319010253.GU5389@shell0.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

1
On Fri, 2005-03-18 at 20:02, Chris Wright wrote:

> I'd prefer that too.  What about the netlink_dev implementation itself?
> Should it be marked obsolete?
> 

It should die - pieces of it have already been slowly disapearing.

cheers,
jamal
