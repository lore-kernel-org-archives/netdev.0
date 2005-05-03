From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 3/3] [RTNETLINK] Cleanup rtnetlink_link tables
Date: Tue, 3 May 2005 14:28:54 -0700
Message-ID: <20050503142854.7097daec.davem@davemloft.net>
References: <20050430195243.GE577@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050430195243.GE577@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 30 Apr 2005 21:52:43 +0200
Thomas Graf <tgraf@suug.ch> wrote:

> Converts remaining rtnetlink_link tables to use c99 designated
> initializers to make greping a little bit easier.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Applied, thanks a lot.
