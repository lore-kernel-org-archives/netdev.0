From: David Miller <davem@davemloft.net>
Subject: Re: Crypto Update for 2.6.21
Date: Thu, 08 Feb 2007 15:26:55 -0800 (PST)
Message-ID: <20070208.152655.104035982.davem@davemloft.net>
References: <20070207154717.GA2757@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-crypto@vger.kernel.org, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20070207154717.GA2757@gondor.apana.org.au>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 8 Feb 2007 02:47:17 +1100

> Here is the crypto update for 2.6.21:
> 
> Please pull from
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/herbert/crypto-2.6.git
> 
> or
> 
> master.kernel.org:/pub/scm/linux/kernel/git/herbert/crypto-2.6.git

Pulled, thanks a lot Herbert.

There was a minor merge conflict to resolve, because the
S390 guys removed a bunch of their crypto options from
crypto/Kconfig in a seperate changeset.  But I'm pretty
sure I resolved that correctly.

Thanks again.
