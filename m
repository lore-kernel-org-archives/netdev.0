From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [TG3] Always load TSO firmware
Date: Thu, 20 Nov 2003 12:59:30 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FBD0102.1010309@pobox.com>
References: <20031117093225.GA12420@gondor.apana.org.au> <20031117123836.2f8e70af.davem@redhat.com> <20031120095605.GA6572@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20031120095605.GA6572@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thanks.

This changes the replenish threshold a bit, but I don't think it will 
adversely affect anything.

Applied to 2.4 and 2.5, and sent upstream.
