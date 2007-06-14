From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [Cbe-oss-dev] [PATCH 0/15] spidernet driver bug fixes
Date: Thu, 14 Jun 2007 19:04:44 -0400
Message-ID: <4671C98C.3060100@garzik.org>
References: <20070607191707.GA7904@austin.ibm.com>	 <1181265151.6026.1.camel@concordia.ozlabs.ibm.com>	 <20070608170608.GI7904@austin.ibm.com>	 <20070608172020.GA31089@havoc.gtf.org>	 <20070611181429.GA4397@austin.ibm.com> <466F2581.2080808@garzik.org>	 <20070612233237.GN4397@austin.ibm.com> <466F3482.4050305@garzik.org>	 <20070613161414.GO4397@austin.ibm.com>	 <1181858908.5211.33.camel@shinybook.infradead.org>	 <4671C8B6.5010000@garzik.org> <1181862191.5211.42.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linas Vepstas <linas@austin.ibm.com>, netdev@vger.kernel.org,
	cbe-oss-dev@ozlabs.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:50849 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752380AbXFNXEr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jun 2007 19:04:47 -0400
In-Reply-To: <1181862191.5211.42.camel@shinybook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Woodhouse wrote:
> On Thu, 2007-06-14 at 19:01 -0400, Jeff Garzik wrote:
>> It makes diffing between lines of development more difficult, takes up
>> more overall space, less cache friendly, ... 
> 
> All of which is much less true if you're sharing object directories or
> even using alternates.

Think about the actual kernel tree source code, not just the metadata...

	Jeff



