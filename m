From: "David S. Miller" <davem@redhat.com>
Subject: Re: [RFC] ethtool semantics
Date: Wed, 9 Jun 2004 15:12:46 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040609151246.1c28c4d9.davem@redhat.com>
References: <20040607212804.GA17012@k3.hellgate.ch>
	<20040607145723.41da5783.davem@redhat.com>
	<20040608210809.GA10542@k3.hellgate.ch>
	<40C77C70.5070409@tmr.com>
	<20040609213850.GA17243@k3.hellgate.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davidsen@tmr.com, jgarzik@pobox.com, netdev@oss.sgi.com,
        linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Roger Luethi <rl@hellgate.ch>
In-Reply-To: <20040609213850.GA17243@k3.hellgate.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 9 Jun 2004 23:38:50 +0200
Roger Luethi <rl@hellgate.ch> wrote:

> <sigh> I just killed the module parameters in my via-rhine development
> tree.

That is absolutely the correct thing to do, module parameters for
link settings are %100 deprecated, people need to use ethtool for
everything.
