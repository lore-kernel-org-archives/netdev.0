From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] PKT_SCHED: dsmark should ignore ECN bits
Date: Mon, 27 Dec 2004 21:54:21 -0800
Message-ID: <20041227215421.7f0326eb.davem@davemloft.net>
References: <20041227193822.GK7884@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20041227193822.GK7884@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 27 Dec 2004 20:38:22 +0100
Thomas Graf <tgraf@suug.ch> wrote:

> Taking ECN bits into account doesn't make sense. The two bits were
> still unused at the time the code was written so this brings back the
> old behaviour.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Looks good, I put this into my 2.4 tree as well.

Thanks.
