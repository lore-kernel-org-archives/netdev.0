From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 00/30] Kernel NET policy
Date: Mon, 18 Jul 2016 22:03:42 -0700 (PDT)
Message-ID: <20160718.220342.805963245855552246.davem@davemloft.net>
References: <20160718194357.GL5871@two.firstfloor.org>
	<1468878674.1778899.669950273.69750E32@webmail.messagingengine.com>
	<37D7C6CF3E00A74B8858931C1DB2F07712C19A4A@SHSMSX103.ccr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, andi@firstfloor.org, fw@strlen.de,
	linux-kernel@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
	netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com,
	mingo@redhat.com, peterz@infradead.org, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	akpm@linux-foundation.org, keescook@chromium.org,
	viro@zeniv.linux.org.uk, gorcunov@openvz.org,
	john.stultz@linaro.org, aduyck@mirantis.com, ben@decadent.org.uk,
	decot@googlers.com, jesse.brandeburg@intel.com
To: kan.liang@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53368 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751280AbcGSFDq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jul 2016 01:03:46 -0400
In-Reply-To: <37D7C6CF3E00A74B8858931C1DB2F07712C19A4A@SHSMSX103.ccr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Liang, Kan" <kan.liang@intel.com>
Date: Tue, 19 Jul 2016 01:49:41 +0000

> Yes, rtnl will bring some overheads. But the configuration is one
> time thing for application or socket. It only happens on receiving
> first packet.

Thanks for destroying our connection rates.

This kind of overhead is simply unacceptable.
