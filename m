From: "David S. Miller" <davem@redhat.com>
Subject: Re: Flow cache flush oops
Date: Thu, 19 Jun 2003 18:47:07 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030619.184707.74741850.davem@redhat.com>
References: <20030619093518.GA27025@gondor.apana.org.au>
	<20030619.121108.21920417.davem@redhat.com>
	<20030619224308.GA32165@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: toml@us.ibm.com, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: herbert@gondor.apana.org.au
In-Reply-To: <20030619224308.GA32165@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Herbert Xu <herbert@gondor.apana.org.au>
   Date: Fri, 20 Jun 2003 08:43:08 +1000
   
   Perhaps we should check that in the init function as well.

Yep, I've applied your patch.

Thanks.
