From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 4/7] d80211: add support for SIOCSIWNICKN SIOCGIWNICKN
Date: Tue, 29 Aug 2006 09:49:17 +0200
Message-ID: <1156837757.3788.10.camel@ux156>
References: <44F3572E.8020506@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jbenc@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:39126 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1750726AbWH2Hsp
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Aug 2006 03:48:45 -0400
To: mabbas <mabbas@linux.intel.com>
In-Reply-To: <44F3572E.8020506@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I intend to kill the nick command with nl80211 since it seems to be
useless. Any objections?

johannes
