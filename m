From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: orinoco driver causes *lots* of lockdep spew
Date: Fri, 04 Aug 2006 04:11:03 +0200
Message-ID: <1154657483.2996.9.camel@laptopd505.fenrus.org>
References: <1154607380.2965.25.camel@laptopd505.fenrus.org>
	 <E1G8der-0001fm-00@gondolin.me.apana.org.au>
	 <20060803195306.GB7079@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, davej@redhat.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net, jt@hpl.hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e-nvb.com ([69.27.17.200]:48005 "EHLO e-nvb.com")
	by vger.kernel.org with ESMTP id S1030289AbWHDCML (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2006 22:12:11 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060803195306.GB7079@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-08-03 at 15:53 -0400, John W. Linville wrote:
> On Thu, Aug 03, 2006 at 11:54:41PM +1000, Herbert Xu wrote:
> Arjan, did you convince yourself whether or not this patch actually
> resolves the problem at hand?  Applying it makes sense to me either
> way, but it would be nice to believe it fixed a known issue. :-)

it'll fix a whole bunch of issues for sure, and this one as well afaics
(now with coffee ;-).. it probably won't fix all of them, but that's ok,
with this in place we actually CAN fix any others that pop up, right now
without this patch we probably can't.

> John
-- 
if you want to mail me at work (you don't), use arjan (at) linux.intel.com

