From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: [Rt2400-devel] [PATCH] rt2x00: Fix compilation for d80211 hwmode API change
Date: Fri, 15 Dec 2006 20:52:38 +0100
Message-ID: <200612152052.39187.IvDoorn@gmail.com>
References: <200612152042.21076.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: rt2400-devel@lists.sourceforge.net, Jiri Benc <jbenc@suse.cz>,
	netdev@vger.kernel.org, John Linville <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:48747 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753335AbWLOTww (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Dec 2006 14:52:52 -0500
Received: by ug-out-1314.google.com with SMTP id 44so899712uga
        for <netdev@vger.kernel.org>; Fri, 15 Dec 2006 11:52:50 -0800 (PST)
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200612152042.21076.mb@bu3sch.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

> This fixes compilation for the d80211 hwmode API change.

I haven't had time yet to look closely at more of the benefits
of the new hwmode API change, but this patch looks good.

Thanks!

> Signed-off-by: Michael Buesch <mb@bu3sch.de>

Signed-off-by: Ivo van Doorn <IvDoorn@gmail.com>
