From: David Miller <davem@davemloft.net>
Subject: Re: copyless virtio net thoughts?
Date: Sat, 07 Feb 2009 19:01:56 -0800 (PST)
Message-ID: <20090207.190156.209878491.davem@davemloft.net>
References: <20090206091904.GA6645@gondor.apana.org.au>
	<498C4F6C.4070402@redhat.com>
	<200902071256.07513.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: avi@redhat.com, herbert@gondor.apana.org.au, chrisw@sous-sol.org,
	rusty@rustcorp.com.au, kvm@vger.kernel.org, netdev@vger.kernel.org
To: arnd@arndb.de
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <200902071256.07513.arnd@arndb.de>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Sat, 7 Feb 2009 12:56:06 +0100

> Having the load spread evenly over all guests sounds like a much rarer
> use case.

Totally agreed.
