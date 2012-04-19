From: "Venkataraman, Meenakshi" <meenakshi.venkataraman@intel.com>
Subject: RE: net-next iwlwifi breaks compile - was Re: pull request:
 wireless-next 2012-04-18
Date: Thu, 19 Apr 2012 21:07:23 +0000
Message-ID: <4595B4D22AB93C4FABBA84AAD5AA37FD1259E6@ORSMSX103.amr.corp.intel.com>
References: <20120418.153653.2130740499995307564.davem@davemloft.net>
	<4F8F9977.9040703@hartkopp.net>
	<4595B4D22AB93C4FABBA84AAD5AA37FD1258AA@ORSMSX103.amr.corp.intel.com>
 <20120419.154954.1322943404183128381.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "socketcan@hartkopp.net" <socketcan@hartkopp.net>,
	"Guy, Wey-Yi W" <wey-yi.w.guy@intel.com>,
	"linville@tuxdriver.com" <linville@tuxdriver.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Spinadel, David" <david.spinadel@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:42527 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932747Ab2DSVHY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 17:07:24 -0400
In-Reply-To: <20120419.154954.1322943404183128381.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

>> It was fixed internally in a subsequent patch, but that patch has not
>> made it into net-next. I don't see it in the public iwlwifi repository
>> either. We'll add the fix to the repository so you can pick it up.
>
>That's not how this works.
>
>You should submit a patch to fix the build directly to me, immediately, so that I
>can push it directly into net-next as fast as possible.

[MV]  Okay -- this is good to know. Essentially -- if any upstream tree breaks due to our work, then a fix should be directly submitted ASAP to the maintainer of that tree.

I see that Wey-Yi has already sent you the fix, so nothing left for me to do on this one.

Thanks,
Meenakshi
