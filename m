From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2.4] PKT_SCHED: break is not enough to stop walking
Date: Mon, 1 Nov 2004 16:58:20 -0800
Message-ID: <20041101165820.75159f20.davem@davemloft.net>
References: <20041029002958.GF12289@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20041029002958.GF12289@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 29 Oct 2004 02:29:58 +0200
Thomas Graf <tgraf@suug.ch> wrote:

> break is not enough to escape from the walking loops, since
> multiple encapsulated loops are used to traverse the hash tables.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Applied, thanks for doing this backport Thomas.
