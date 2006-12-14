From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH 6/6] d80211: add sysfs interface for QoS functions
Date: Thu, 14 Dec 2006 12:23:39 +0100
Message-ID: <20061214122339.37fc6b6d@griffin.suse.cz>
References: <20061214040302.GA10689@mail.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:53395 "EHLO mail.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932621AbWLNLXQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Dec 2006 06:23:16 -0500
To: yi.zhu@intel.com
In-Reply-To: <20061214040302.GA10689@mail.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 14 Dec 2006 12:03:02 +0800, Zhu Yi wrote:
> The sysfs interface here is only a proof of concept. It provides a way for
> the userspace applications to use the advanced QoS features supported by
> d80211 stack. The finial solution should be switched to cfg80211.

So... what about implementing that into cfg80211? :-)

I'm not inclined towards this patch (even if you address Stephen's
comment).

Thanks,

 Jiri

(Btw, it will take me some time to review patches 4 and 5.)

-- 
Jiri Benc
SUSE Labs
