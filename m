From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [RFC] string matching ematch
Date: Wed, 26 Jan 2005 15:26:09 -0800
Message-ID: <20050126152609.59e1a15e.davem@davemloft.net>
References: <20050126150714.GL31837@postel.suug.ch>
	<20050126130323.2dc10187.davem@davemloft.net>
	<20050126214119.GP31837@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, kaber@trash.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050126214119.GP31837@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 26 Jan 2005 22:41:19 +0100
Thomas Graf <tgraf@suug.ch> wrote:

> I'm not sure if mixing stateful with stateless stuff is such of a good
> idea. I think it should be separated and have stateful filters only be
> executed when the flow matters, not packets.

I think keeping things totally stateless would be the best
idea.
