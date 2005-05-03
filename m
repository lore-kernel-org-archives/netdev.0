From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 1/2] [XFRM] Prevent off-by-one access to xfrm_dispatch
Date: Tue, 3 May 2005 14:25:15 -0700
Message-ID: <20050503142515.1c3c5d8e.davem@davemloft.net>
References: <20050501184731.GJ577@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050501184731.GJ577@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 1 May 2005 20:47:31 +0200
Thomas Graf <tgraf@suug.ch> wrote:

> Makes the type > XFRM_MSG_MAX check behave correctly to
> protect access to xfrm_dispatch.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Applied, thanks Thomas.
