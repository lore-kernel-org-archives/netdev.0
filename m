From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 03/18] d80211:  pointers as extended booleans
Date: Tue, 22 Aug 2006 10:39:25 +0200
Message-ID: <1156235965.3621.18.camel@ux156>
References: <20060821074107.648561364@sipsolutions.net>
	 <20060821075159.171461075@sipsolutions.net>
	 <20060822024301.611aa4de.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jkm@devicescape.com,
	linville@tuxdriver.com, jbenc@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:17898 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1751367AbWHVIi5
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Aug 2006 04:38:57 -0400
To: Bill Fink <billfink@mindspring.com>
In-Reply-To: <20060822024301.611aa4de.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-08-22 at 02:43 -0400, Bill Fink wrote:

> Just a minor nit.  I don't believe the "()" on the first new line
> are needed.

Good point. Weren't even needed before when that was still == NULL :)

Thanks,
johannes
