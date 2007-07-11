From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] Virtual ethernet device (v2.1)
Date: Wed, 11 Jul 2007 19:32:52 +0200
Message-ID: <46951444.6090209@trash.net>
References: <4694A363.2070406@openvz.org> <4694CBD9.90503@trash.net> <4694D0C5.6020700@openvz.org> <4694D2CC.10409@trash.net> <4694D473.3080707@openvz.org> <4694D741.80906@trash.net> <4694DBE6.4080702@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Ben Greear <greearb@candelatech.com>, devel@openvz.org,
	Kirill Korotaev <dev@openvz.org>
To: Pavel Emelianov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:58214 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753837AbXGKRcy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2007 13:32:54 -0400
In-Reply-To: <4694DBE6.4080702@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pavel Emelianov wrote:
> OK. I'll try to make the generic call. Could you please send me the
> patches with IFLA_ADDRESS support for booth kernel and ip utility.


I'll send the kernel patches seperately in a few minutes. iproute
doesn't need any further patches.
