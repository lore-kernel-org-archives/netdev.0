From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 02/18] d80211:  master link
Date: Tue, 22 Aug 2006 09:49:19 +0200
Message-ID: <1156232959.3621.8.camel@ux156>
References: <20060821074107.648561364@sipsolutions.net>
	 <20060821075159.017613319@sipsolutions.net>
	 <20060821210818.75a0f398@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jouni Malinen <jkm@devicescape.com>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:46784 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S932067AbWHVHss
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Aug 2006 03:48:48 -0400
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20060821210818.75a0f398@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-08-21 at 21:08 +0200, Jiri Benc wrote:

> Please add proper error handling and remove the link when the master
> device is unregistered.

Whoops, good points.

johannes
