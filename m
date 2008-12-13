From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 00/11]: error/return path joining
Date: Sat, 13 Dec 2008 21:21:11 +0200
Message-ID: <1229196082-4162-1-git-send-email-ilpo.jarvinen@helsinki.fi>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:51986 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751190AbYLMTVX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Dec 2008 14:21:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Less copy-paste and even saves some bytes here and there though
the amount are not earth-shattering, ~20 bytes at most (x86_64).

My apologies for the duplicates, it seems that Cc's didn't get
caught on the first attempt correctly (I hope this one ends up
being better).

--
 i.


