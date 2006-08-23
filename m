From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 01/18] d80211:  LED triggers
Date: Wed, 23 Aug 2006 09:02:25 +0200
Message-ID: <1156316545.3629.2.camel@ux156>
References: <20060821074107.648561364@sipsolutions.net>
	 <20060821075158.728615077@sipsolutions.net>
	 <20060822165402.GI13240@instant802.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:9694 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1751437AbWHWHBv
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 03:01:51 -0400
To: Jouni Malinen <jkm@devicescape.com>
In-Reply-To: <20060822165402.GI13240@instant802.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-08-22 at 09:54 -0700, Jouni Malinen wrote:

> Is someone using these or planning on using them? I have been open to
> just removing all code due to lack of active use.

Some people on powerbooks want to use the front LED for wireless
activity instead of other things, and a few weeks ago I wrote a LED
class device for it so they could hook it up now :)

johannes
