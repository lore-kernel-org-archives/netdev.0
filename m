From: Brian Haley <Brian.Haley@hp.com>
Subject: Re: node-local multicast issues
Date: Wed, 10 Nov 2004 14:46:34 -0500
Message-ID: <4192701A.3090908@hp.com>
References: <OF18E2258F.5E2E252A-ON88256F47.007FA9FD-88256F47.0080590C@us.ibm.com> <1100096251.22964.7.camel@mn-2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Mark Borst <mark@borst.org>
In-Reply-To: <1100096251.22964.7.camel@mn-2>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Mark Borst wrote:

> On another note: 'ping6 ff02::1' gives "connect: Invalid argument" on
> linux.

You've got to use -I with that, maybe ping6 could give a hint.

> The only implementation that gives me replies is Solaris.

My trusty Tru64 UNIX box works as well :)

-Brian
