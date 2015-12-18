From: <zyjzyj2000@gmail.com>
Subject: Re: [PATCH 1/1] bonding: restrict up state in 802.3ad mode
Date: Fri, 18 Dec 2015 12:36:25 +0800
Message-ID: <1450413386-8867-1-git-send-email-zyjzyj2000@gmail.com>
References: <1586.1450389436@famine>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <vfalico@gmail.com>, <gospo@cumulusnetworks.com>,
	<netdev@vger.kernel.org>, <Boris.Shteinbock@windriver.com>
To: <j.vosburgh@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail5.windriver.com ([192.103.53.11]:53988 "EHLO mail5.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933572AbbLREgO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Dec 2015 23:36:14 -0500
In-Reply-To: <1586.1450389436@famine>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi, Jay

Thanks for your reply.

Yes. The NIC is a bit odd. We have to be compatible with it.
I followed your advice to delay calling netif_carrier_on().

Changes:
Delay calling netif_carrier_on().

Best Regards!
Zhu Yanjun
