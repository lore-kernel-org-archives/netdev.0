From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/7] NetLabel: core network changes
Date: Fri, 28 Jul 2006 12:58:16 -0700 (PDT)
Message-ID: <20060728.125816.10299135.davem@davemloft.net>
References: <44CA59D8.4090702@hp.com>
	<20060728185825.GG14627@postel.suug.ch>
	<44CA60BC.1030503@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org, selinux@tycho.nsa.gov,
	sds@epoch.ncsc.mil, jmorris@redhat.com, pratt@argus-systems.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:57541
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030301AbWG1T6Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Jul 2006 15:58:16 -0400
To: paul.moore@hp.com
In-Reply-To: <44CA60BC.1030503@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paul Moore <paul.moore@hp.com>
Date: Fri, 28 Jul 2006 15:08:44 -0400

> Thanks for your feedback but unless I hear from others that this
> is a requirement I think I'm going to leave the code as written for the
> reasons I listed above.

Please switch over to the scheme which Thomas has suggested.

There are real solid reasons for doing this, even if you think
your API is complete today and won't run into some of the
issues he mentioned.
