From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [3/3] [TCP] Dump SYN_RECV sockets in tcpdiag
Date: Tue, 19 Oct 2004 22:11:05 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041019221105.53e68281.davem@davemloft.net>
References: <4164F60C.6080807@cosmosbay.com>
	<E1CFTUz-0007V6-00@gondolin.me.apana.org.au>
	<20041014213030.GA18433@gondor.apana.org.au>
	<20041014213347.GB18433@gondor.apana.org.au>
	<20041014213517.GC18433@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20041014213517.GC18433@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 15 Oct 2004 07:35:17 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Finally this patch adds the code to list SYN_RECV sockets.  A future
> enhancement would be to do this for the GET operation as well.
>   
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Also applied, thanks for fixing all of this Herbert.

Feel free to make the mentioned GET enhancement :-)
