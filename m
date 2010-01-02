From: Amit Salecha <amit.salecha@qlogic.com>
Subject: RE: [PATCH 0/2] netxen: ethtool fixes
Date: Sat, 2 Jan 2010 07:11:21 -0600
Message-ID: <99737F4847ED0A48AECC9F4A1974A4B80CFE943438@MNEXMB2.qlogic.org>
References: <1262176758-17803-1-git-send-email-amit.salecha@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Dhananjay Phadke <dhananjay.phadke@qlogic.com>
To: "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:19661 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752193Ab0ABNNG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jan 2010 08:13:06 -0500
In-Reply-To: <1262176758-17803-1-git-send-email-amit.salecha@qlogic.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please do not apply these patches, 1) netxen: fix ethtool register dump and  2) netxen: fix ethtool link test.
"netxen-fix-ethtool-register-dump.patch" has potential panic bug. 
I am resubmitting reworked patches as v2.

Thanks
Amit Salecha
________________________________________
From: netdev-owner@vger.kernel.org [netdev-owner@vger.kernel.org] On Behalf Of Amit Kumar Salecha [amit.salecha@qlogic.com]
Sent: Wednesday, December 30, 2009 6:09 PM
To: davem@davemloft.net
Cc: netdev@vger.kernel.org; Dhananjay Phadke
Subject: [PATCH 0/2] netxen: ethtool fixes

Hi
 Series of two ethtool fixes, please apply to net-2.6.

-Amit
--
To unsubscribe from this list: send the line "unsubscribe netdev" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html