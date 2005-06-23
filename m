From: Prasanna Meda <pmeda@akamai.com>
Subject: Re: [patch] devinet: cleanup if statements
Date: Thu, 23 Jun 2005 11:13:45 -0700
Message-ID: <42BAFBD9.80B28D89@akamai.com>
References: <E1DlQ1w-0003yI-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, jgarzik@pobox.com, akpm@osdl.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:

>
>
> With your interpretation above his patch is correct as well.  If
> we want to use the label when it is different from the device name,
> then it is equivalent to always use the label since the only time
> we'd use the device name is when it's equal to the label :)

Sounds correct to me. Actually I did not think about second
interpretation in first.

Thanks,
Prasanna.
