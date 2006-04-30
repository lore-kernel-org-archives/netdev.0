From: Dan Williams <dcbw@redhat.com>
Subject: Re: [AX25, ROSE] Remove useless SET_MODULE_OWNER calls.
Date: Sun, 30 Apr 2006 13:04:20 -0400
Message-ID: <1146416660.2336.0.camel@localhost.localdomain>
References: <E1FaC7e-0003Cj-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: ralf@linux-mips.org, davem@davemloft.net, netdev@vger.kernel.org,
	linux-hams@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:58074 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1751173AbWD3RGZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Apr 2006 13:06:25 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1FaC7e-0003Cj-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2006-04-30 at 23:38 +1000, Herbert Xu wrote:
> Dan Williams <dcbw@redhat.com> wrote:
> > 
> > Are these done by anything else now?  Did something change to make
> > SET_MODULE_OWNER useless in individual drivers?  I'm asking because I
> 
> SET_MODULE_OWNER has been a no-op ever since Dave made live network
> device driver modules unloadable nearly three years ago.

Ah, thanks for the clarification.

dan


