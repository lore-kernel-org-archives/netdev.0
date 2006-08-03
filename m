From: Dave Jones <davej@redhat.com>
Subject: Re: orinoco driver causes *lots* of lockdep spew
Date: Thu, 3 Aug 2006 14:59:27 -0400
Message-ID: <20060803185927.GB11577@redhat.com>
References: <1154607380.2965.25.camel@laptopd505.fenrus.org> <E1G8der-0001fm-00@gondolin.me.apana.org.au> <20060803141153.GB20405@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:24449 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1030182AbWHCTC5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2006 15:02:57 -0400
To: Christoph Hellwig <hch@infradead.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Arjan van de Ven <arjan@infradead.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net, linville@tuxdriver.com, jt@hpl.hp.com
Content-Disposition: inline
In-Reply-To: <20060803141153.GB20405@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 03, 2006 at 03:11:53PM +0100, Christoph Hellwig wrote:

 > Could we please just get rid of the wireless extensions over netlink code
 > again?  It doesn't help to solve anything and just creates a bigger mess
 > to untangle when switching to a fully fledged wireless stack.

If we're going to do that, now is probably the best time to do it,
before any distro userland starts using it.

		Dave

-- 
http://www.codemonkey.org.uk
