From: Bryan O'Donoghue <pure.logic@nexus-software.ie>
Subject: Re: [PATCH v3 3/3] stmmac: pci: add MSI support for Intel Quark X1000
Date: Mon, 02 Feb 2015 15:17:19 +0000
Message-ID: <54CF94FF.1050802@nexus-software.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org,
	"Kweh, Hock Leong" <hock.leong.kweh@intel.com>,
	Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
	davem@davemloft.net, "Ahmad, Josef" <josef.ahmad@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outbound-smtp03.blacknight.com ([81.17.249.16]:33128 "EHLO
	outbound-smtp03.blacknight.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753735AbbBBPZ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2015 10:25:59 -0500
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp03.blacknight.com (Postfix) with ESMTPS id E9C8E2F8194
	for <netdev@vger.kernel.org>; Mon,  2 Feb 2015 15:17:22 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi guys.

Has the issue with PVM masking been addressed ?

https://lkml.org/lkml/2014/10/1/221

If not then please drop MSIs from this patchset.

--
Bryan
