From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [RFC 0/4] pktgen patches
Date: Tue, 25 Aug 2009 23:15:13 -0700
Message-ID: <20090826061513.755294685@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Robert Olsson <Robert.Olsson@data.slu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:36521 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752004AbZHZGZ7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Aug 2009 02:25:59 -0400
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These are some experimental (not ready yet), patches to try and
improve the pktgen timer code. Need some review by the hrtimer folks
as well.


-- 

