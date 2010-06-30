From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] netfilter: remove deprecated config
 option NF_CT_ACCT
Date: Wed, 30 Jun 2010 10:48:37 -0700 (PDT)
Message-ID: <20100630.104837.236230876.davem@davemloft.net>
References: <4C2B3E3D.7030804@trash.net>
	<20100630131153.GB2582@psychotron.brq.redhat.com>
	<4C2B49B9.5050302@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jpirko@redhat.com, netdev@vger.kernel.org, ole@ans.pl
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35856
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751695Ab0F3RsY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jun 2010 13:48:24 -0400
In-Reply-To: <4C2B49B9.5050302@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Wed, 30 Jun 2010 15:42:17 +0200

> I usually leave those for the architecture maintainers.

Right, that's how this is supposed to work.  If we update defconfigs
every time we make some Kconfig change it's going to be nothing but
pain for arch folks.
