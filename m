From: "Yaniv Rosner" <yaniv.rosner@broadcom.com>
Subject: ethtool enhancement proposal
Date: Wed, 18 Apr 2012 13:05:24 +0000
Message-ID: <A6AA2EF896BED345B0F23520D832A4B10583EC@SJEXCHMB05.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Ben Hutchings" <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3608 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751263Ab2DRNFr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Apr 2012 09:05:47 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ben,
I want to propose new enhancement for the ethtool to display the content of attached SFP+ module.
The format should be similar to the "-e" option, and optionally parse it's content based on SFF-8472.
Please let me know what you think.

Thanks,
Yaniv
