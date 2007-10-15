From: David Miller <davem@davemloft.net>
Subject: Re: [IPV6]: Uninline netfilter okfns
Date: Mon, 15 Oct 2007 01:51:49 -0700 (PDT)
Message-ID: <20071015.015149.112834140.davem@davemloft.net>
References: <20071014042604.GA11431@gondor.apana.org.au>
	<47131D64.3080008@trash.net>
	<4713251B.4070208@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, hadi@cyberus.ca,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37871
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750810AbXJOIvo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2007 04:51:44 -0400
In-Reply-To: <4713251B.4070208@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Mon, 15 Oct 2007 10:30:19 +0200

> Turns out IPv6 only has two functions which are marked inline
> and where gcc is able to generate tail-calls, bridging doesn't
> have a single one.

Applied, thanks Patrick!

