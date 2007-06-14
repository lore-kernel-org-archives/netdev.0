From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [Cbe-oss-dev] [PATCH 0/15] spidernet driver bug fixes
Date: Fri, 15 Jun 2007 00:03:11 +0100
Message-ID: <1181862191.5211.42.camel@shinybook.infradead.org>
References: <20070607191707.GA7904@austin.ibm.com>
	 <1181265151.6026.1.camel@concordia.ozlabs.ibm.com>
	 <20070608170608.GI7904@austin.ibm.com>
	 <20070608172020.GA31089@havoc.gtf.org>
	 <20070611181429.GA4397@austin.ibm.com> <466F2581.2080808@garzik.org>
	 <20070612233237.GN4397@austin.ibm.com> <466F3482.4050305@garzik.org>
	 <20070613161414.GO4397@austin.ibm.com>
	 <1181858908.5211.33.camel@shinybook.infradead.org>
	 <4671C8B6.5010000@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Linas Vepstas <linas@austin.ibm.com>, netdev@vger.kernel.org,
	cbe-oss-dev@ozlabs.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:52125 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752050AbXFNXCl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jun 2007 19:02:41 -0400
In-Reply-To: <4671C8B6.5010000@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-06-14 at 19:01 -0400, Jeff Garzik wrote:
> It makes diffing between lines of development more difficult, takes up
> more overall space, less cache friendly, ... 

All of which is much less true if you're sharing object directories or
even using alternates.

-- 
dwmw2

