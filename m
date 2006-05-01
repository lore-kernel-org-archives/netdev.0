From: Michael Buesch <mb@bu3sch.de>
Subject: [PATCH] bcm43xx-d80211: remove sta_up script
Date: Mon, 1 May 2006 23:10:27 +0200
Message-ID: <200605012310.27446.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bcm43xx-dev@lists.berlios.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:44993
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S932262AbWEAVE1
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 May 2006 17:04:27 -0400
To: "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi John,

This is not really a patch, because it is easier for you
to do it manually. :)

Please remove the file
scripts/bcm43xx-d80211-sta_up.sh
from the wireless-dev tree, as the d80211 user interface has
been fixed and it is not really needed anymore.

While you are at it, please also remove
Documentation/networking/bcm43xx-d80211-HOWTO.txt
Documentation/networking/bcm43xx-d80211.txt
as they are completely outdated and useless these days.

Thanks.

PS: If someone wants to update
Documentation/networking/bcm43xx.txt
please feel free to submit a patch.

-- 
Greetings Michael.
