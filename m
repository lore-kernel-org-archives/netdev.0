From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [IPv4] Missing TOS checks after fib_find_alias
Date: Thu, 23 Sep 2004 13:38:50 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040923133850.2ed1b7ab.davem@davemloft.net>
References: <20040923062831.GA20202@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040923062831.GA20202@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 23 Sep 2004 16:28:31 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> It looks like some of the places where FIB_SCAN_TOS macros were used
> have lost the tos check.  This patch adds them back.

Right you are, patch applied.

Thanks Herbert.
