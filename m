From: Mark Borst <mark@borst.org>
Subject: Re: node-local multicast issues
Date: Thu, 11 Nov 2004 12:18:24 +0200
Message-ID: <1100168304.24452.5.camel@mn-2>
References: <OF18E2258F.5E2E252A-ON88256F47.007FA9FD-88256F47.0080590C@us.ibm.com>
	 <1100096251.22964.7.camel@mn-2>  <4192701A.3090908@hp.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Brian Haley <Brian.Haley@hp.com>
In-Reply-To: <4192701A.3090908@hp.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2004-11-10 at 14:46 -0500, Brian Haley wrote:
> Mark Borst wrote:
> 
> > On another note: 'ping6 ff02::1' gives "connect: Invalid argument" on
> > linux.
> 
> You've got to use -I with that, maybe ping6 could give a hint.

I found that too. With -I it works fine.

> 
> > The only implementation that gives me replies is Solaris.
> 
> My trusty Tru64 UNIX box works as well :)

Good ;) My testing wasn't anything near exhaustive, just a short test ;)


-- 
Mark Borst
Researcher
Network and Protocols Group
Tampere University of Technology, Finland
