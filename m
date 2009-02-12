From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 00/41]bnx2x: enhancements and clean up for net-next
Date: Thu, 12 Feb 2009 20:36:03 +0200
Message-ID: <1234463763.1863.131.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Yaniv Rosner" <yanivr@broadcom.com>,
	"Harvey Harrison" <harvey.harrison@gmail.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1546 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755237AbZBLSg0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Feb 2009 13:36:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

Finally, an enhancement patch for the bnx2x. Due to many reasons (among
which FW stability and chasing some bugs) it took a while to stabilize
and the longer it took the longer the list got. So unfortunately, this
is a long list - hopefully for the last time. I realize that sending a
too many patches together is bad practice and I will do my best to avoid
it in the future.

The first patch is a new FW patch. It is way too big for the mailing
list, but I'm hoping you will get it directly to your mailbox. This
patch has very little review value since it is simply the new FW blob,
FW header file renames and the mandatory driver renames to accommodate
it.

Please consider applying to net-next.

Thanks,
Eilon



