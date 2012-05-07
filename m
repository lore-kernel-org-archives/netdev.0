From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: New commands to configure IOV features
Date: Mon, 7 May 2012 14:17:54 +0300
Message-ID: <4FA7AF62.8000405@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Ben Hutchings" <bhutchings@solarflare.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: gregory.v.rose@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1353 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755405Ab2EGLUI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 May 2012 07:20:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've tried to figure out if there was a standard interface
(ethtool/iproute) through which a user could configure the number
of vfs in his system.

I've seen the RFC suggested in http://markmail.org/thread/qblfcv7zbxsxp7q6,
and http://markmail.org/thread/fw54dcppmxuxoe6n, but failed to see any
later references to it (commits or further discussion on this topic).

How exactly are things standing with these RFCs? Were they abandoned?

Thanks,
Yuval
