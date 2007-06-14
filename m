From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [Cbe-oss-dev] [PATCH 0/15] spidernet driver bug fixes
Date: Thu, 14 Jun 2007 23:08:27 +0100
Message-ID: <1181858908.5211.33.camel@shinybook.infradead.org>
References: <20070607191707.GA7904@austin.ibm.com>
	 <1181265151.6026.1.camel@concordia.ozlabs.ibm.com>
	 <20070608170608.GI7904@austin.ibm.com>
	 <20070608172020.GA31089@havoc.gtf.org>
	 <20070611181429.GA4397@austin.ibm.com> <466F2581.2080808@garzik.org>
	 <20070612233237.GN4397@austin.ibm.com> <466F3482.4050305@garzik.org>
	 <20070613161414.GO4397@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	cbe-oss-dev@ozlabs.org
To: Linas Vepstas <linas@austin.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:36363 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751048AbXFNWIL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jun 2007 18:08:11 -0400
In-Reply-To: <20070613161414.GO4397@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-06-13 at 11:14 -0500, Linas Vepstas wrote:
> Some googling seems to show that "git pull" has a bug/feature of
> ignoring the branch that one is working in, and pulling "master"
> no matter what.  I have no clue why; this seems broken to me.

Branches are generally a PITA -- it's probably best just to avoid them
entirely. It's not as if it's hard to create separate trees, and even
share objects between the trees.

-- 
dwmw2

