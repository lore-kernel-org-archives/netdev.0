From: "Julius Volz" <juliusv@google.com>
Subject: Re: Gentle Guide to the Network Stack
Date: Wed, 18 Jun 2008 01:51:06 +0200
Message-ID: <f4845fc0806171651t37bee728j9389d5a84f16c73@mail.gmail.com>
References: <200806171105.23069.okir@lst.de>
	 <20080617145655.GB16229@synapse.neuralscape.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Olaf Kirch" <okir@lst.de>, netdev@vger.kernel.org
To: "Karen Shaeffer" <shaeffer@neuralscape.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:42205 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750956AbYFQXvO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2008 19:51:14 -0400
Received: from spaceape14.eur.corp.google.com (spaceape14.eur.corp.google.com [172.28.16.148])
	by smtp-out.google.com with ESMTP id m5HNp7hR014737
	for <netdev@vger.kernel.org>; Wed, 18 Jun 2008 00:51:07 +0100
Received: from yw-out-1718.google.com (ywm5.prod.google.com [10.192.13.5])
	by spaceape14.eur.corp.google.com with ESMTP id m5HNp7cE016545
	for <netdev@vger.kernel.org>; Wed, 18 Jun 2008 00:51:07 +0100
Received: by yw-out-1718.google.com with SMTP id 5so3017261ywm.32
        for <netdev@vger.kernel.org>; Tue, 17 Jun 2008 16:51:06 -0700 (PDT)
In-Reply-To: <20080617145655.GB16229@synapse.neuralscape.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 17, 2008, Karen Shaeffer wrote:
> I suggest you take a close look at O'Reilly's "Understanding
> Linux Network Internals" as a jumping off point. This work
> deals with IPv4 Layer 3, and L2 implementations for the 2.6
> kernel.

Yes, very nice book! It also mentions explicitly in the beginning that
it doesn't cover Netfilter, IPv6, IPVS and perhaps some other topics.
Of course, these were exactly the topics I was most interested in, so
there's a suggestion for further writings ;)

Otherwise, very nice and easy to follow writing style in your paper,
Olaf! Although it looks like it will be turning more into a small book
than a paper...

Julius

-- 
Google Switzerland GmbH
