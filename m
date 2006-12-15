From: Zhu Yi <yi.zhu@intel.com>
Subject: Re: [PATCH 2/6] d80211: create "wifi.h" to define WIFI OUIs
Date: Fri, 15 Dec 2006 11:22:36 +0800
Message-ID: <1166152956.2929.93.camel@debian.sh.intel.com>
References: <20061214040216.GA10652@mail.intel.com>
	 <20061214113150.54523e61@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:20374 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751742AbWLODZA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Dec 2006 22:25:00 -0500
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20061214113150.54523e61@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-12-14 at 11:31 +0100, Jiri Benc wrote:
> AFAIK "wifi" is a trademark and we want to avoid using it. "wlan" seems
> to be a better alternative for the prefixes. Also, I don't see a reason
> for a separate header file here.

WI-FI(r) is a trademark, but wifi and WIFI_XXX are not. I'm OK with
putting these to existed headers.

Thanks,
-yi
