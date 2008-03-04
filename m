From: "Stephens, Allan" <allan.stephens@windriver.com>
Subject: RE: [PATCH 1/7 net-2.6.26] [TIPC]: Update version to 1.6.3
Date: Tue, 4 Mar 2008 14:01:34 -0800
Message-ID: <AF1602CB2550CE4381C0C75118A7856B0252E54B@ala-mail02.corp.ad.wrs.com>
References: <1204665619-6345-1-git-send-email-allan.stephens@windriver.com><1204665619-6345-2-git-send-email-allan.stephens@windriver.com> <20080304.134056.13379327.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:58469 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755314AbYCDWBo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 17:01:44 -0500
Content-class: urn:content-classes:message
In-Reply-To: <20080304.134056.13379327.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

That's a good point.  I'll include this as the last patch when I
resubmit (since it turned out you really didn't like the rest of the
patch set).

-- Al

-----Original Message-----
From: David Miller [mailto:davem@davemloft.net] 
Sent: Tuesday, March 04, 2008 4:41 PM
To: Stephens, Allan
Cc: netdev@vger.kernel.org
Subject: Re: [PATCH 1/7 net-2.6.26] [TIPC]: Update version to 1.6.3

From: Allan Stephens <allan.stephens@windriver.com>
Date: Tue,  4 Mar 2008 16:20:13 -0500

> This patch updates TIPC's version number to 1.6.3.
> 
> Signed-off-by: Allan Stephens <allan.stephens@windriver.com>

You should bump version numbers after actually making changes.  What if
I didn't like the rest of your patch set, and I only applied this one?
