From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH] e1000: Don't enable polling in open() (was: e1000:	assertion
 hit in e1000_clean(), kernel 2.6.21.1)
Date: Wed, 23 May 2007 16:38:20 -0700
Message-ID: <4654D06C.9030600@intel.com>
References: <20070521215134.14885.84952.stgit@localhost.localdomain> <46522E6F.9060600@garzik.org> <20070522010137.GC8130@gondor.apana.org.au> <465320A6.80706@redhat.com> <4653223D.2010108@intel.com> <20070523104711.GA24332@gondor.apana.org.au> <20070523233418.GA3391@sequoia.sous-sol.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Chris Wright <chrisw@sous-sol.org>,
	Chuck Ebbert <cebbert@redhat.com>,
	Jeff Garzik <jeff@garzik.org>, stable@kernel.org,
	Greg KH <greg@kroah.com>, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, davej@redhat.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:63678 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755709AbXEWXix (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 May 2007 19:38:53 -0400
In-Reply-To: <20070523233418.GA3391@sequoia.sous-sol.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chris Wright wrote:
> * Herbert Xu (herbert@gondor.apana.org.au) wrote:
>> On Tue, May 22, 2007 at 10:02:53AM -0700, Kok, Auke wrote:
>>> I've posted that before and it's up to the stable team. I think that it's a 
>>> seriously toolarge change unless Herbert posts his short version of the fix 
>>> for 2.6.21.1. I would be OK with that.
>> This patch should work for 2.6.21.
> 
> Mind adding an updated changelog and signed-off-by please?

Herbert,

With that, please add my Acked-By...

Auke
