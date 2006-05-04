From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH 1/3] d80211: get rid of default management interface
Date: Thu, 4 May 2006 11:02:30 +0200
Message-ID: <20060504110230.1e8ec409@griffin.suse.cz>
References: <20060503171031.304543000.midnight@suse.cz>
	<20060503151128.70354482B3@silver.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:7123 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1751447AbWEDJCb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 May 2006 05:02:31 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060503151128.70354482B3@silver.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed,  3 May 2006 17:11:28 +0200 (CEST), Jiri Benc wrote:
> Default management interface (wmasterXap) confuses users. It is only needed
> for AP mode (and only until the new netlink interface between kernel and
> hostapd is implemented).

Please don't apply this patch.

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
