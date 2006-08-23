From: Jason Borg <jcborg@somanetworks.com>
Subject: [PATCH 0/5] smc911x: Bug fixes
Date: Wed, 23 Aug 2006 15:15:47 -0400
Message-ID: <1156360547.15824.70.camel@borg.yyz.somanetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: dustin@sensoria.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ldap.somanetworks.com ([216.126.67.42]:45213 "EHLO
	mail.somanetworks.com") by vger.kernel.org with ESMTP
	id S932324AbWHWTPw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 15:15:52 -0400
Received: from borg.yyz.somanetworks.com ([10.11.11.252])
          (envelope-sender <jcborg@somanetworks.com>)
          by mail.somanetworks.com (qmail-ldap-1.03) with SMTP
          for <netdev@vger.kernel.org>; 23 Aug 2006 19:15:47 -0000
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

This set of patches contain some fixes for the smc911x driver.
My testing was done using the Smsc LAN9115 ethernet chip.  The
patches were done against 2.6.18-rc4.

Thanks,
Jason


