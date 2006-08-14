From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: network manager confused with bcm43xx-d80211?
Date: Mon, 14 Aug 2006 14:54:39 +0200
Message-ID: <44E0728F.10103@sipsolutions.net>
References: <44E02F41.2060300@sipsolutions.net> <44E031D2.8070106@sipsolutions.net> <1155556011.2885.3.camel@localhost.localdomain> <44E06C8B.1040400@sipsolutions.net> <44E07116.6060208@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Dan Williams <dcbw@redhat.com>,
	Michael Buesch <mbuesch@freenet.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:42137 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1752019AbWHNMyw
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Aug 2006 08:54:52 -0400
To: Larry Finger <Larry.Finger@lwfinger.net>
In-Reply-To: <44E07116.6060208@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Larry Finger wrote:
> The RFCd patch to add wireless stats to d80211 received only minor 
> comments, which have all been addressed. I will be submitting a proper 
> patch to Linville's tree today. In addition, I have reached an 
> agreement with the authors of all other drivers that use d80211 on a 
> scheme that will implement the stats code for them as well. 
> Unfortunately, none of them provide such useful quantities as noise 
> values, but perhaps the prominent FIXMEs will spur action by those who 
> have detailed device specifications.

Sounds good to me, thanks :) I'll take a look at bcm43xx signal 
strength/quality reverse engineering, I promise. Just have to get to it, 
right now I'm using a rt2500usb device which doesn't seem to give any 
useful values.

johannes
