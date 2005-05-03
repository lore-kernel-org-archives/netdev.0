From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2/2] [XFRM] Cleanup xfrm_msg_min and xfrm_dispatch
Date: Tue, 3 May 2005 14:25:55 -0700
Message-ID: <20050503142555.5b795eeb.davem@davemloft.net>
References: <20050501185548.GK577@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050501185548.GK577@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 1 May 2005 20:55:48 +0200
Thomas Graf <tgraf@suug.ch> wrote:

> Converts xfrm_msg_min and xfrm_dispatch to use c99 designated
> initializers to make greping a little bit easier. Also replaces
> two hardcoded message type with meaningful names.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Applied, thanks.
