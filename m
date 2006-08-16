From: Johannes Berg <johannes@sipsolutions.net>
Subject: [rt2500usb] link led weirdness
Date: Wed, 16 Aug 2006 15:02:58 +0200
Message-ID: <1155733378.3600.23.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:53379 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1751167AbWHPNCe
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Aug 2006 09:02:34 -0400
To: Ivo van Doorn <ivdoorn@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hey,

I just noticed that my rt2500usb device turns on the link LED when I
just add an active monitor interface. I can't imagine that being on
purpose, but I'm not sure based on what it is controlled.

johannes
