From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: mac80211: NOHZ: local_softirq_pending 08
Date: Tue, 29 Sep 2009 15:29:28 -0400
Message-ID: <20090929192928.GF2678@tuxdriver.com>
References: <200909111648.50902.mb@bu3sch.de> <200909111707.23971.mb@bu3sch.de> <4AAA75CB.6040803@hartkopp.net> <200909111813.35810.mb@bu3sch.de> <4AABCF28.6090505@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Buesch <mb@bu3sch.de>, Kalle Valo <kalle.valo@iki.fi>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Johannes Berg <johannes@sipsolutions.net>
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:56405 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753948AbZI2Tax (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2009 15:30:53 -0400
Content-Disposition: inline
In-Reply-To: <4AABCF28.6090505@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 12, 2009 at 06:41:12PM +0200, Oliver Hartkopp wrote:

> i cooked a patch that introduces netif_rx_ti() and fixes up the problems in
> mac80211 and the CAN subsystem.

Oliver,

Are you going to send this patch to Dave?  If you want me to carry
it instead, please resend it with a proper changelog including a
Signed-off-by line.  For that matter, Dave will most certainly want
that as well...

Thanks!

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
