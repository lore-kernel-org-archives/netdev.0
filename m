From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH][NET] make all protos partially use sk_prot
Date: Thu, 31 Mar 2005 21:19:13 -0800
Message-ID: <20050331211913.7a88d339.davem@davemloft.net>
References: <20050326232317.GA24264@conectiva.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: marcel@holtmann.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: acme@ghostprotocols.net (Arnaldo Carvalho de Melo)
In-Reply-To: <20050326232317.GA24264@conectiva.com.br>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 26 Mar 2005 20:23:17 -0300
acme@ghostprotocols.net (Arnaldo Carvalho de Melo) wrote:

>         Here is an updated patch, with the preferred changed for bluetooth
> by Marcel.
> 
>         Full description on the changeset comments.
> 
>         Available at:
> 
> bk://kernel.bkbits.net/acme/net-2.6

Anything that cleanly gets rid of 2 struct sock members
gets my approval. :-)

Pulled, thanks a lot Arnaldo.
