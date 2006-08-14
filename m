From: Johannes Berg <johannes@sipsolutions.net>
Subject: ieee80211_japan_5ghz / firmware etc.??
Date: Mon, 14 Aug 2006 10:16:02 +0200
Message-ID: <44E03142.2030307@sipsolutions.net>
References: <44E02F41.2060300@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:50820 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1750870AbWHNIQI
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Aug 2006 04:16:08 -0400
To: Jiri Benc <jbenc@suse.cz>, Jouni Malinen <jkm@devicescape.com>
In-Reply-To: <44E02F41.2060300@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I think we need to get rid of this parameter and if really necessary 
have this information passed from the lowlevel driver to the stack.

johannes
