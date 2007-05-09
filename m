From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH] [SCTP]: More bugfixes
Date: Wed,  9 May 2007 15:43:47 -0400
Message-ID: <11787398302375-git-send-email-vladislav.yasevich@hp.com>
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel6.hp.com ([156.153.255.205]:39378 "EHLO atlrel6.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755230AbXEITn4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 May 2007 15:43:56 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi David

This is yet more bugfixes for SCTP:

      [SCTP] Prevent OOPS if hmac modules didn't load
      [SCTP] Correctly copy addresses in sctp_copy_laddrs
      [SCTP] Do not include ABORT chunk header in the notification.


Please apply.

Thanks
-vlad
