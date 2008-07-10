From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH v2] rc80211_pid: Fix fast_start parameter handling
Date: Thu, 10 Jul 2008 12:40:07 +0200
Message-ID: <20080710104007.GB30650@elte.hu>
References: <19f34abd0807070427w5398c617uae0a4e8e40fd8f0e@mail.gmail.com> <1215464899.4416.22.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vegard Nossum <vegard.nossum@gmail.com>,
	Stefano Brivio <stefano.brivio@polimi.it>,
	"John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	Pekka Enberg <penberg@cs.helsinki.fi>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Mattias Nissler <mattias.nissler@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:43812 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752751AbYGJKk1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jul 2008 06:40:27 -0400
Content-Disposition: inline
In-Reply-To: <1215464899.4416.22.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Mattias Nissler <mattias.nissler@gmx.de> wrote:

> [...] This also fixes uninitialized memory references to the 
> fast_start and norm_offset parameters detected by the kmemcheck 
> utility.

cool :-)

	Ingo
