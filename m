From: Jan Glauber <jan.glauber@de.ibm.com>
Subject: Re: Crypto Update for 2.6.21
Date: Fri, 09 Feb 2007 13:45:07 +0100
Message-ID: <1171025107.5349.4.camel@localhost.localdomain>
References: <20070207154717.GA2757@gondor.apana.org.au>
	 <20070208.152655.104035982.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, linux-crypto@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20070208.152655.104035982.davem@davemloft.net>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-02-08 at 15:26 -0800, David Miller wrote:

> There was a minor merge conflict to resolve, because the
> S390 guys removed a bunch of their crypto options from
> crypto/Kconfig in a seperate changeset.  But I'm pretty
> sure I resolved that correctly.

I'll check when the git server works again...

Would it be better if I send patches that also touch common crypto
code to Herbert for integration?

Jan
