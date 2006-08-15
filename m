From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH wireless-dev] d80211: switch status codes, reason codes,
 and EIDs to enums
Date: Tue, 15 Aug 2006 09:45:00 +0200
Message-ID: <44E17B7C.8030406@sipsolutions.net>
References: <200608131243.51185.flamingice@sourmilk.net> <44E02C2A.2010701@sipsolutions.net> <200608140940.35759.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Linville <linville@tuxdriver.com>, netdev@vger.kernel.org,
	Jiri Benc <jbenc@suse.cz>, Jouni Malinen <jkm@devicescape.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:9351 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S965279AbWHOHpY
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Aug 2006 03:45:24 -0400
To: Michael Wu <flamingice@sourmilk.net>
In-Reply-To: <200608140940.35759.flamingice@sourmilk.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Wu wrote:
> I don't really like the comments in the EID section. I would rather have the 
> comments resemble the ones in ieee80211_statuscode which identifies 
> 802.11b/h/g/i instead of just pointing out the ones that are 802.11h. If you 
> want to do that, that would be great, though I can probably get to it in a 
> few days.
>   
I'm currently torn between needing some things here for work, and doing 
that work. I'd prefer if you did it, I can at earliest do it on the weekend.

johannes
