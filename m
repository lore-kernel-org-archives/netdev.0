From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build failure after merge of the net-next tree
Date: Wed, 20 Jun 2012 01:41:32 -0700 (PDT)
Message-ID: <20120620.014132.2222580541940208799.davem@davemloft.net>
References: <20120619.213703.513466167861199217.davem@davemloft.net>
	<D5ECB3C7A6F99444980976A8C6D896384FAA275CBE@EAPEX1MAIL1.st.com>
	<4FE18A5E.204@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhupesh.sharma@st.com, sfr@canb.auug.org.au,
	netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, federico.vaga@gmail.com,
	giancarlo.asnaghi@st.com, wg@grandegger.com
To: mkl@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35520 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754512Ab2FTIld (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jun 2012 04:41:33 -0400
In-Reply-To: <4FE18A5E.204@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marc Kleine-Budde <mkl@pengutronix.de>
Date: Wed, 20 Jun 2012 10:31:26 +0200

> I think the driver is currently used/tested only on ARM only, so what
> about adding a HAVE_CLK dependency, until Viresh Kumar's patches are
> available in net-next. Later we can remove it.

Sounds good.
