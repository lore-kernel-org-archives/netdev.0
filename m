From: Rajesh Borundia <rajesh.borundia@qlogic.com>
Subject: RE: [PATCH] netxen: check for root bus in
 netxen_mask_aer_correctable
Date: Wed, 19 Sep 2012 02:24:29 -0500
Message-ID: <13A253B3F9BEFE43B93C09CF75F63CAA827E3AEA05@MNEXMB1.qlogic.org>
References: <1347637803-4837-1-git-send-email-nikolay@redhat.com>
	<13A253B3F9BEFE43B93C09CF75F63CAA827E3AE9F9@MNEXMB1.qlogic.org>,<20120918.162321.1283398796161136088.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "nikolay@redhat.com" <nikolay@redhat.com>,
	Sony Chacko <sony.chacko@qlogic.com>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [216.32.180.11] ([216.32.180.11]:23449 "EHLO
	va3outboundpool.messaging.microsoft.com" rhost-flags-FAIL-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753701Ab2ISH1h convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Sep 2012 03:27:37 -0400
In-Reply-To: <20120918.162321.1283398796161136088.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


________________________________________
From: David Miller [davem@davemloft.net]
Sent: Wednesday, September 19, 2012 1:53 AM
To: Rajesh Borundia
Cc: nikolay@redhat.com; Sony Chacko; netdev
Subject: Re: [PATCH] netxen: check for root bus in netxen_mask_aer_correctable

No, this is not the correct way to submit patches written by other
people.

Look at how people like Jeff Kirsher submits Intel driver patches
written by people other than himself.

Apologies, will follow the guideline.
