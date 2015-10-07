From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [MM PATCH V4.1 5/6] slub: support for bulk free with SLUB
 freelists
Date: Wed, 7 Oct 2015 08:44:56 -0700
Message-ID: <20151007154456.GJ26924@tassilo.jf.intel.com>
References: <20150930114255.13505.2618.stgit@canyon>
 <20151001151015.c59a1360c7720a257f655578@linux-foundation.org>
 <20151002114118.75aae2f9@redhat.com>
 <20151002154039.69f82bdc@redhat.com>
 <20151002145044.781c911ea98e3ea74ae5cf3b@linux-foundation.org>
 <20151005212639.35932b6c@redhat.com>
 <20151005212045.GG26924@tassilo.jf.intel.com>
 <20151006010703.09e2f0ff@redhat.com>
 <20151007143120.7068416d@redhat.com>
 <20151007133619.GR12682@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, linux-mm@kvack.org,
	netdev@vger.kernel.org
To: Arnaldo Carvalho de Melo <acme@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:13805 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753954AbbJGPpD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Oct 2015 11:45:03 -0400
Content-Disposition: inline
In-Reply-To: <20151007133619.GR12682@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> There is a recent patch that may help here, see below, but maybe its
> just a matter of removing that :pp, as it ends with a /pp anyway, no
> need to state that twice :)

Yes the extra :pp was a regression in toplev. I fixed it now. Thanks.

-Andi
