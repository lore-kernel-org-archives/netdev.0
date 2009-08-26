From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: Page allocation failures in guest
Date: Wed, 26 Aug 2009 11:47:17 +0930
Message-ID: <200908261147.17838.rusty@rustcorp.com.au>
References: <20090713115158.0a4892b0@mjolnir.ossman.eu> <200908121501.53167.rusty@rustcorp.com.au> <20090813222548.5e0743dd@mjolnir.ossman.eu>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Avi Kivity <avi@redhat.com>, Minchan Kim <minchan.kim@gmail.com>,
	kvm@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	linux-mm@kvack.org, Wu Fengguang <fengguang.wu@intel.com>,
	KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>,
	Rik van Riel <riel@redhat.com>, netdev@vger.kernel.org
To: Pierre Ossman <drzeus-list@drzeus.cx>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:48797 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751697AbZHZCRW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Aug 2009 22:17:22 -0400
In-Reply-To: <20090813222548.5e0743dd@mjolnir.ossman.eu>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 14 Aug 2009 05:55:48 am Pierre Ossman wrote:
> On Wed, 12 Aug 2009 15:01:52 +0930
> Rusty Russell <rusty@rustcorp.com.au> wrote:
> > Subject: virtio: net refill on out-of-memory
... 
> Patch applied. Now we wait. :)

Any results?

Thanks,
Rusty.
