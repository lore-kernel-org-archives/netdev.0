From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH][ATM]: don't leak skb on as_indicate failure; don't
 wakeup twice on as_close
Date: Wed, 27 Oct 2004 14:49:55 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041027144955.2a824e22.davem@davemloft.net>
References: <200410271432.i9REWql8004243@ginger.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "chas williams (contractor)" <chas@cmf.nrl.navy.mil>
In-Reply-To: <200410271432.i9REWql8004243@ginger.cmf.nrl.navy.mil>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 27 Oct 2004 10:32:54 -0400
"chas williams (contractor)" <chas@cmf.nrl.navy.mil> wrote:

> please apply to 2.6.
 ...
> # ChangeSet
> #   2004/10/27 09:58:17-04:00 chas@relax.cmf.nrl.navy.mil 
> #   [ATM]: don't leak skb on as_indicate failure; don't wakeup twice on as_close

Applied, thanks Chas.
