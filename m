From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 00/34]bnx2x: Bug fixes
Date: Wed, 14 Jan 2009 18:42:35 +0200
Message-ID: <1231951356.11301.121.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Paul Larson" <pl@linux.vnet.ibm.com>,
	"Yaniv Rosner" <yanivr@broadcom.com>
To: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1343 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759243AbZANQn2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jan 2009 11:43:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

While developing new features and testing them on different platforms,
bugs were discovered. It took a while to get a clean version and to
identify which of the bugs are relevant to the existing published
version (as apposed to bugs that were introduced with the new features).
The problem is that more and more bugs required immediate attention so
the result is a long list of bug fixes.

I hope that in the future I will have enough space between bugs to allow
sending each fix when found. But today, I have a long list...

Please consider applying.

Thanks,
Eilon


