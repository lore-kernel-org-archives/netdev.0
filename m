From: Dexuan Cui <decui@microsoft.com>
Subject: When will net-next merge with linux-next?
Date: Mon, 14 Mar 2016 06:09:41 +0000
Message-ID: <BLUPR03MB14106249C57CCF66717CC860BF880@BLUPR03MB1410.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: KY Srinivasan <kys@microsoft.com>,
	Haiyang Zhang <haiyangz@microsoft.com>
To: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0137.outbound.protection.outlook.com ([65.55.169.137]:11439
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751525AbcCNGmr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2016 02:42:47 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,
I have a pending patch of the hv_sock driver, which should go into the
kernel through the net-next tree:
https://lkml.org/lkml/2016/2/14/7

The VMBus side's supporting patches of hv_sock have been in Greg's tree
and linux-next for more than 1 month, but they haven't been in net-next
yet, I suppose this is because of the releasing of 4.5.

Now 4.5 is released. Will you merge with Greg's tree or linux-next?

I read netdev-FAQ.txt, but still don't have a clear idea about how things
work in my case.

Thanks,
-- Dexuan
