From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2.6]: keep fragment queues private to each user
Date: Wed, 26 Jan 2005 22:29:55 -0800
Message-ID: <20050126222955.729c390b.davem@davemloft.net>
References: <41F5D1CB.9050804@trash.net>
	<20050125214158.4be3798c.davem@davemloft.net>
	<41F82830.9010009@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <41F82830.9010009@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 27 Jan 2005 00:30:56 +0100
Patrick McHardy <kaber@trash.net> wrote:

> Sorry, new patch attached. I'll send the 2.4 patch later tonight.

Thanks.  I'll apply this and the 2.4.x variant.

Although I have a theoretical objection to this thing.  It is
extending a namespace we have no such control over.  The namespace
is saddr/daddr/ID.  But perhaps I'm being overly anal.
