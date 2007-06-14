From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [Cbe-oss-dev] [PATCH 0/15] spidernet driver bug fixes
Date: Thu, 14 Jun 2007 19:01:10 -0400
Message-ID: <4671C8B6.5010000@garzik.org>
References: <20070607191707.GA7904@austin.ibm.com>	 <1181265151.6026.1.camel@concordia.ozlabs.ibm.com>	 <20070608170608.GI7904@austin.ibm.com>	 <20070608172020.GA31089@havoc.gtf.org>	 <20070611181429.GA4397@austin.ibm.com> <466F2581.2080808@garzik.org>	 <20070612233237.GN4397@austin.ibm.com> <466F3482.4050305@garzik.org>	 <20070613161414.GO4397@austin.ibm.com> <1181858908.5211.33.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linas Vepstas <linas@austin.ibm.com>, netdev@vger.kernel.org,
	cbe-oss-dev@ozlabs.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:50810 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752697AbXFNXBP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jun 2007 19:01:15 -0400
In-Reply-To: <1181858908.5211.33.camel@shinybook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Woodhouse wrote:
> On Wed, 2007-06-13 at 11:14 -0500, Linas Vepstas wrote:
>> Some googling seems to show that "git pull" has a bug/feature of
>> ignoring the branch that one is working in, and pulling "master"
>> no matter what.  I have no clue why; this seems broken to me.
> 
> Branches are generally a PITA -- it's probably best just to avoid them
> entirely. It's not as if it's hard to create separate trees, and even
> share objects between the trees.

It makes diffing between lines of development more difficult, takes up 
more overall space, less cache friendly, ...

	Jeff



