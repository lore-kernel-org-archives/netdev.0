From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [ATM] Fix flags type in lec_arp_expire_vcc
Date: Wed, 26 Jan 2005 22:20:35 -0800
Message-ID: <20050126222035.715ec67e.davem@davemloft.net>
References: <20050126233820.GA24422@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: chas@cmf.nrl.navy.mil, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050126233820.GA24422@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 27 Jan 2005 10:38:20 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> The variable flags in lec_arp_expire_vcc should be of type
> unsigned long and not unsigned.  The following patch fixes
> that typo.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks Herbert.
