From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Ipsec-tools-devel] Re: [PATCH 2.6]: Check against correct policy list in ip_forward/ip6_forward
Date: Wed, 20 Oct 2004 07:26:06 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041019212606.GB16127@gondor.apana.org.au>
References: <4172943B.8050904@trash.net> <20041017212317.GA28615@gondor.apana.org.au> <4172F1AB.4020305@trash.net> <20041017231258.GA29294@gondor.apana.org.au> <4175334B.3000504@gmc.lt>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, "David S. Miller" <davem@redhat.com>,
        netdev@oss.sgi.com, ipsec-tools-devel@lists.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Aidas Kasparas <a.kasparas@gmc.lt>
Content-Disposition: inline
In-Reply-To: <4175334B.3000504@gmc.lt>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Oct 19, 2004 at 06:31:23PM +0300, Aidas Kasparas wrote:
> 
> I'm sorry, what is wrong with racoon?

For tunnel SAs it needs to add forward policies as well as incoming
policies.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
