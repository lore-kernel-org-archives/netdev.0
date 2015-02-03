From: Hariprasad S <hariprasad@chelsio.com>
Subject: RE: [PATCH net-next 2/8] cxgb4: Added support in debugfs to display
 tp_la stats
Date: Tue, 3 Feb 2015 05:00:17 +0000
Message-ID: <26E3F92EC670BD429DB5CB319D773C13C843C7@nice.asicdesigners.com>
References: <1422888789-12016-1-git-send-email-hariprasad@chelsio.com>
	<1422888789-12016-3-git-send-email-hariprasad@chelsio.com>,<20150202.131436.102902508236295371.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Casey Leedom <leedom@chelsio.com>,
	Anish Bhatt <anish@chelsio.com>,
	Nirranjan Kirubaharan <nirranjan@chelsio.com>,
	Praveen Madhavan <praveenm@chelsio.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:26318 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750741AbbBCFAV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Feb 2015 00:00:21 -0500
In-Reply-To: <20150202.131436.102902508236295371.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

Will send a V2. For now will send only busy_poll.

Thanks,
Hari
________________________________________
From: David Miller [davem@davemloft.net]
Sent: Tuesday, February 03, 2015 2:44 AM
To: Hariprasad S
Cc: netdev@vger.kernel.org; Casey Leedom; Anish Bhatt; Nirranjan Kirubaharan; Praveen Madhavan
Subject: Re: [PATCH net-next 2/8] cxgb4: Added support in debugfs to display tp_la stats

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Mon,  2 Feb 2015 20:23:03 +0530

> Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>

Ok I've seen enough.

You guys really, truly, abuse debugfs.  So I'm putting my foot down now.

Stats like this can be exported through traditional means such as via
ethtool.
