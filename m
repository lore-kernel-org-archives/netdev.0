From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 02/18] d80211:  master link
Date: Mon, 21 Aug 2006 10:13:34 +0200
Message-ID: <1156148015.10324.2.camel@ux156>
References: <20060821074107.648561364@sipsolutions.net>
	 <20060821075159.017613319@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jouni Malinen <jkm@devicescape.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:62657 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1030296AbWHUINF
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Aug 2006 04:13:05 -0400
To: netdev@vger.kernel.org
In-Reply-To: <20060821075159.017613319@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-08-21 at 09:41 +0200, Johannes Berg wrote:
> +	sysfs_create_link(&local->class_dev.kobj, &dev->class_dev.kobj, "master");

Whoops, with the long line again, and then I fix it in patch 13. I suck
at this ;)

johannes
