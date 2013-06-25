From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH v2 0/7] alx: small fixes/cleanups
Date: Tue, 25 Jun 2013 20:38:16 +0200
Message-ID: <1372185503-24705-1-git-send-email-johannes@sipsolutions.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:41270 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751269Ab3FYSi2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jun 2013 14:38:28 -0400
Received: by sipsolutions.net with esmtpsa (TLS1.2:DHE_RSA_AES_256_CBC_SHA256:256)
	(Exim 4.80)
	(envelope-from <johannes@sipsolutions.net>)
	id 1UrY8J-0003om-HC
	for netdev@vger.kernel.org; Tue, 25 Jun 2013 20:38:27 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks to Ben's review mostly, here are some fixes/cleanups in
alx. I'm seriously considering removing WoWLAN as I have no use
for it and am not too motivated to debug it, anyone else want
to try debugging? :)

johannes
