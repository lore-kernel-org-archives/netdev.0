From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH][ATM]: use RCV_SHUTDOWN to exit skb_recv_datagram()
Date: Wed, 20 Oct 2004 22:07:16 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041020220716.29c7d10b.davem@davemloft.net>
References: <200410182056.i9IKuL2s022173@ginger.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: chas@cmf.nrl.navy.mil, netdev@oss.sgi.com, davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: chas3@users.sourceforge.net
In-Reply-To: <200410182056.i9IKuL2s022173@ginger.cmf.nrl.navy.mil>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 18 Oct 2004 16:56:22 -0400
"chas williams (contractor)" <chas@cmf.nrl.navy.mil> wrote:

> this patch makes the svc socket protocol act a little more like
> a connection oriented protocol.  please apply to 2.6.

Applied, thanks Chas.

Feel free to provide "Signed-off-by: Chas Williams <chas@....>"
lines in the future.

Thanks again.
