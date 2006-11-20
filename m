From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH 0/13] move d80211 away from netdev towards wiphy
Date: Mon, 20 Nov 2006 20:14:02 +0100
Message-ID: <20061120201402.76e69e46@griffin.suse.cz>
References: <1163802439.3392.47.camel@johannes.berg>
	<1163963898.15473.36.camel@johannes.berg>
	<1163979143.9216.14.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Simon Barber <simon@devicescape.com>,
	Jouni Malinen <jkm@devicescape.com>,
	Hong Liu <hong.liu@intel.com>,
	David Kimdon <david.kimdon@devicescape.com>,
	Michael Wu <flamingice@sourmilk.net>,
	Michael Buesch <mbuesch@freenet.de>,
	Ivo van Doorn <ivdoorn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:62113 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S966448AbWKTTOF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Nov 2006 14:14:05 -0500
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1163979143.9216.14.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 20 Nov 2006 00:32:23 +0100, Johannes Berg wrote:
> Since d80211 also should relinquish control of this to cfg80211 I
> decided that it was a good idea to make cfg80211 handle the wiphy stuff.
> Also, I think cfg80211 should create /sys/class/ieee80211/<wiphy> to
> allow renaming to follow through in sysfs.

Sounds good.

 Jiri

-- 
Jiri Benc
SUSE Labs
