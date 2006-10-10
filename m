From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [patch 5/5] d80211: allow wireless vlan interface to
	havesameMAC an AP interface
Date: Tue, 10 Oct 2006 15:47:57 +0200
Message-ID: <1160488077.2727.14.camel@ux156>
References: <20061003181118.537800000@devicescape.com>
	 <20061003181233.GE19403@devicescape.com>
	 <1160343128.4701.6.camel@johannes.berg>
	 <20061009213807.GH26254@instant802.com> <1160477427.2727.8.camel@ux156>
	 <20061010134226.GA4518@devicescape.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jouni Malinen <jkm@devicescape.com>, netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:38092 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1750791AbWJJNrJ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Oct 2006 09:47:09 -0400
To: David Kimdon <david.kimdon@devicescape.com>
In-Reply-To: <20061010134226.GA4518@devicescape.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-10-10 at 06:42 -0700, David Kimdon wrote:

> no, still broadcasts, but in a typical deployment some for of encryption
> is used.  Each vlan has a unique broadcast key so stations on one vlan
> cannot decrypt packets from another vlan. 

Oh ok, that makes sense. Thanks.

johannes
