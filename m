From: David Miller <davem@davemloft.net>
Subject: Re: TOE, etc.
Date: Wed, 28 Jun 2006 11:36:46 -0700 (PDT)
Message-ID: <20060628.113646.85408870.davem@davemloft.net>
References: <20060627.214323.92582051.davem@davemloft.net>
	<20060628053554.GA5928@gondor.apana.org.au>
	<1151506497.14895.51.camel@stevo-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, jgarzik@pobox.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:7644
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750924AbWF1Sgq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Jun 2006 14:36:46 -0400
To: swise@opengridcomputing.com
In-Reply-To: <1151506497.14895.51.camel@stevo-desktop>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Steve Wise <swise@opengridcomputing.com>
Date: Wed, 28 Jun 2006 09:54:57 -0500

> Doesn't iSCSI have this same issue?

Software iSCSI implementations don't have the issue because
they go through the stack using normal sockets and normal
device send and receive.
