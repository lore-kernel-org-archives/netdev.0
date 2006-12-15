From: Zhu Yi <yi.zhu@intel.com>
Subject: Re: [PATCH 6/6] d80211: add sysfs interface for QoS functions
Date: Fri, 15 Dec 2006 11:27:43 +0800
Message-ID: <1166153263.2929.98.camel@debian.sh.intel.com>
References: <20061214040302.GA10689@mail.intel.com>
	 <20061214122339.37fc6b6d@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:41504 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751743AbWLODaH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Dec 2006 22:30:07 -0500
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20061214122339.37fc6b6d@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-12-14 at 12:23 +0100, Jiri Benc wrote:
> So... what about implementing that into cfg80211? :-)
> 
> I'm not inclined towards this patch (even if you address Stephen's
> comment). 

OK. This is only for my testing (or maybe someone else wants to try the
code). I'm not asking to merge it. When all the other code is reviewed
and accepted, I will write a cfg80211 interface for it.

Thanks,
-yi
