From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC] nl80211 + packet injection with it and d80211
Date: Mon, 21 Aug 2006 08:44:52 +0200
Message-ID: <1156142692.3669.11.camel@ux156>
References: <1155824008.3491.7.camel@ux156>  <1155912565.5671.1.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:14980 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S965005AbWHUGoW
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Aug 2006 02:44:22 -0400
To: netdev@vger.kernel.org
In-Reply-To: <1155912565.5671.1.camel@ux156>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Another thing that crossed my mind: Should we have a netlink call for
adding virtual interfaces as well? Because then, the ipw2x00 drivers can
have their monitor interface(s) added the same way.

johannes
