From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC] [PATCH 2/3] adds ieee80211_regdomains support
Date: Tue, 24 Oct 2006 10:33:17 +0200
Message-ID: <1161678798.2840.9.camel@ux156>
References: <43e72e890610231547k3cf6c590r4abd0a6fe7965fda@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	Jean Tourrilhes <jt@hpl.hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:26303 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S965110AbWJXIcP
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Oct 2006 04:32:15 -0400
To: "Luis R. Rodriguez" <mcgrof@gmail.com>
In-Reply-To: <43e72e890610231547k3cf6c590r4abd0a6fe7965fda@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> and adds support for PtMP (Point
> to MultiPoint) and PtP (Point to Point) type restrictions.

What are those restrictions?

Similar comments here, why do you build the list at module init time
instead of having it static?

Also, do we really need all this data in the kernel?

johannes
