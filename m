From: BALAKUMARAN KANNAN <balakumarank@tataelxsi.co.in>
Subject: how routing table maintained
Date: Thu, 19 Jul 2012 12:41:10 +0000
Message-ID: <4A71D24947E78D43BC584A7CD4391A41017DD9AB@SIXPRD0410MB359.apcprd04.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe002.messaging.microsoft.com ([216.32.181.182]:20422
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750894Ab2GSMlj convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jul 2012 08:41:39 -0400
Received: from mail141-ch1 (localhost [127.0.0.1])	by
 mail141-ch1-R.bigfish.com (Postfix) with ESMTP id B52C840501	for
 <netdev@vger.kernel.org>; Thu, 19 Jul 2012 12:41:38 +0000 (UTC)
Received: from CH1EHSMHS021.bigfish.com (snatpool1.int.messaging.microsoft.com
 [10.43.68.248])	by mail141-ch1.bigfish.com (Postfix) with ESMTP id 7C185C0043
	for <netdev@vger.kernel.org>; Thu, 19 Jul 2012 12:41:37 +0000 (UTC)
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I want to know how routing table and routing cache is maintained. I can find some entries in cache even after the route is deleted from the routing table. Is it possible to delete an entry(the particular entry or flush the entire cache) from the cache once it is deleted from the main routing table.

Thank you

--Regards
K.Balakumaran
