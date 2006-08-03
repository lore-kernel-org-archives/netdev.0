From: Arjan van de Ven <arjan@linux.intel.com>
Subject: Re: orinoco driver causes *lots* of lockdep spew
Date: Thu, 03 Aug 2006 12:45:05 -0700
Message-ID: <44D25241.6040906@linux.intel.com>
References: <1154607380.2965.25.camel@laptopd505.fenrus.org> <E1G8der-0001fm-00@gondolin.me.apana.org.au> <20060803141153.GB20405@infradead.org> <20060803185800.GB12062@bougret.hpl.hp.com> <20060803185958.GC11577@redhat.com> <20060803194019.GA12152@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Dave Jones <davej@redhat.com>, netdev@vger.kernel.org,
	Christoph Hellwig <hch@infradead.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Arjan van de Ven <arjan@infradead.org>,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([143.182.124.22]:15460 "EHLO
	azsmga101.ch.intel.com") by vger.kernel.org with ESMTP
	id S964870AbWHCTqd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Aug 2006 15:46:33 -0400
To: jt@hpl.hp.com
In-Reply-To: <20060803194019.GA12152@bougret.hpl.hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jean Tourrilhes wrote:
> 	Jean
> 
> P.S. : By the way, don't ask me why it took four years for this bug to
> get discovered...

that I could answer: Only from 2.6.18-rc1 onwards does the kernel have a built in deadlock finder :)
