From: Johannes Berg <johannes@sipsolutions.net>
Subject: RE: [clarification request] ieee80211_tx_control.pkt_type
Date: Mon, 21 Aug 2006 09:21:20 +0200
Message-ID: <1156144880.3669.23.camel@ux156>
References: <C86180A8C204554D8A3323D8F6B0A29F0165B19D@dhost002-46.dex002.intermedia.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jouni Malinen <jkm@devicescape.com>, netdev@vger.kernel.org,
	Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:36285 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1030285AbWHUHUu
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Aug 2006 03:20:50 -0400
To: Simon Barber <simon@devicescape.com>
In-Reply-To: <C86180A8C204554D8A3323D8F6B0A29F0165B19D@dhost002-46.dex002.intermedia.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-08-18 at 09:25 -0700, Simon Barber wrote:
> It might be appropriate to change it from pkt_type to a flag indicating
> that a timestamp should be added at TX time "add_timestamp". This may
> well also end up being used for beacons too on hardware where the
> beacons are completely software generated.

I'll leave that to you or Jouni, was merely asking about the uses :)

Thanks,
johannes
