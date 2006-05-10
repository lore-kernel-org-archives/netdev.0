From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH 4/6] myri10ge - First half of the driver
Date: Wed, 10 May 2006 15:06:11 -0700
Message-ID: <ada8xp97cx8.fsf@cisco.com>
References: <446259A0.8050504@myri.com>
	<Pine.GSO.4.44.0605101438410.498-100000@adel.myri.com>
	<20060510150112.46a732d4@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Brice Goglin <bgoglin@myri.com>, netdev@vger.kernel.org,
	Andrew Morton <akpm@osdl.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"Andrew J. Gallatin" <gallatin@myri.com>, <brice@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-4.cisco.com ([171.68.10.86]:33457 "EHLO
	sj-iport-4.cisco.com") by vger.kernel.org with ESMTP
	id S965036AbWEJWGR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 May 2006 18:06:17 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060510150112.46a732d4@localhost.localdomain> (Stephen Hemminger's message of "Wed, 10 May 2006 15:01:12 -0700")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

    Stephen> Splitting it in half, might help email restrictions, but
    Stephen> it kills future users of 'git bisect' who expect to have
    Stephen> every kernel buildable.

Not really, since the makefile/kconfig stuff comes in a later patch.

But yes, it is cleaner to have drivers go in in sane pieces.

 - R.
