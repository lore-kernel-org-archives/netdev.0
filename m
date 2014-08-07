From: David Hollis <dhollis@davehollis.com>
Subject: [PATCH] asix - Add support for LyconSys FiberGecko
Date: Thu,  7 Aug 2014 11:53:45 -0400
Message-ID: <1407426826-11335-1-git-send-email-dhollis@davehollis.com>
Cc: David Hollis <dhollis@davehollis.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.davehollis.com ([66.77.138.211]:58466 "EHLO
	mail.davehollis.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932169AbaHGQAI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Aug 2014 12:00:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reported-by: Sven Kreiensen <s.kreiensen@lyconsys.com>
Signed-off-by: David Hollis <dhollis@davehollis.com>

David Hollis (1):
  asix - Add support for LyconSys FiberGecko

 drivers/net/usb/asix_devices.c | 25 ++++++++++++++++++++++++-
 1 file changed, 24 insertions(+), 1 deletion(-)

-- 
1.8.3.1
