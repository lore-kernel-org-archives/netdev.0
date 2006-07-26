From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH Round 4 2/3] Core network changes to support network
 event notification.
Date: Wed, 26 Jul 2006 13:56:42 -0700 (PDT)
Message-ID: <20060726.135642.89059962.davem@davemloft.net>
References: <1153839940.14354.37.camel@stevo-desktop>
	<20060726033951.GB3203@gondor.apana.org.au>
	<1153930543.8155.22.camel@stevo-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, rdreier@cisco.com,
	openib-general@openib.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:19181
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750772AbWGZU4j (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Jul 2006 16:56:39 -0400
To: swise@opengridcomputing.com
In-Reply-To: <1153930543.8155.22.camel@stevo-desktop>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Steve Wise <swise@opengridcomputing.com>
Date: Wed, 26 Jul 2006 11:15:43 -0500

> Dave, what do you think about removing the user-space stuff for the
> first round of integration?  IE:  Just add netevents and kernel hooks to
> generate them.

Sure.
