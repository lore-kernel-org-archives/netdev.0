From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] Too aggressive cwnd backoff
Date: Thu, 7 Apr 2005 14:45:07 -0700
Message-ID: <20050407144507.3695f373.davem@davemloft.net>
References: <20050407113351.17f8c094.davem@davemloft.net>
	<E1DJelW-0007Vg-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: baruch@ev-en.org, shemminger@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1DJelW-0007Vg-00@gondolin.me.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 08 Apr 2005 07:42:18 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Looking at the vger tree this was introduced back in 2000:
> 
> # ChangeSet
> #   2000/08/09 11:59:05-00:00 davem@vger.kernel.org
> #   Many files:
> #     Merge in ANKs net-000808-23:20 patch.
> #     Linus better eat this.

Heh, wish I was better at changelog messages back in the
CVS days :-)
