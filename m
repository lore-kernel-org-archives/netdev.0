From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: [PATCH] remove net_init.c ifdef clutter
Date: Sun, 14 Nov 2004 04:40:24 -0200
Message-ID: <4196FDD8.7000302@conectiva.com.br>
References: <20041101130144.GA8727@lst.de>	<20041110165641.GA29705@lst.de> <20041111145058.0fc24412.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Christoph Hellwig <hch@lst.de>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20041111145058.0fc24412.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



David S. Miller wrote:
> On Wed, 10 Nov 2004 17:56:42 +0100
> Christoph Hellwig <hch@lst.de> wrote:
> 
> 
>>On Mon, Nov 01, 2004 at 02:01:44PM +0100, Christoph Hellwig wrote:
>>
>>>Move the devicetype-specific functions from net_init.c to the
>>>devicetype-specific files under net/.
>>
>>ping?  still applies fine against current BK.
> 
> 
> Applied, thanks Christoph.

Dave, you missed the new file net/appletalk/dev.c, i.e. it is not
in Linus tree.

- Arnaldo
