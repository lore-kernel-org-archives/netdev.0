From: David Miller <davem@davemloft.net>
Subject: Re: [patch] r8169: fix crash when large packets are received
Date: Mon, 08 Jun 2009 19:57:09 -0700 (PDT)
Message-ID: <20090608.195709.158667574.davem@davemloft.net>
References: <4A2D8B8B.80905@gmail.com>
	<1244511638.30733.41.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, mjt@tls.msk.ru,
	linux-kernel@vger.kernel.org, romieu@fr.zoreil.com,
	stable@kernel.org
To: jonathan@jonmasters.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35385
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753154AbZFIC5I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2009 22:57:08 -0400
In-Reply-To: <1244511638.30733.41.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Masters <jonathan@jonmasters.org>
Date: Mon, 08 Jun 2009 21:40:38 -0400

> CC -stable team - remote DoS with this hardware present.

"remote", if on the same physical subnet, otherwise easily protectable
if not impossible to trigger
