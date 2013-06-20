From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH 0/6] alx: small fixes and cleanups
Date: Fri, 21 Jun 2013 00:14:48 +0200
Message-ID: <1371766494-18979-1-git-send-email-johannes@sipsolutions.net>
Cc: ben@decadent.org.uk
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:49176 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030247Ab3FTWPB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jun 2013 18:15:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The first two are technically fixes, but I'm not sure it's worthwhile
putting them into net at this point. For the first, I simply don't
think many people use ethtool to override pause parameters. As far as
the second one is concerned, I'm not even sure what the effect is.

Thanks Ben! I'll look into the flow control negotiation another day.

johannes
