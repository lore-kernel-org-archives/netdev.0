From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 4/4] mac80211-hwsim: enable better rx-status when using
 netlink.
Date: Tue, 14 Apr 2015 10:17:08 +0200
Message-ID: <1428999428.3019.11.camel@sipsolutions.net>
References: <1428095523-374-1-git-send-email-greearb@candelatech.com>
	 <1428095523-374-4-git-send-email-greearb@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:54386 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753649AbbDNIRL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Apr 2015 04:17:11 -0400
In-Reply-To: <1428095523-374-4-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-04-03 at 14:12 -0700, greearb@candelatech.com wrote:

> +/**
> + * This relates to the ieee80211_rx_status struct in mac80211.h
> + * @rx_flags: %RX_FLAG_* (see  mac80211_rx_flags)
> + * @vht_flags: %RX_VHT_FLAG_*

Same here.

johannes
