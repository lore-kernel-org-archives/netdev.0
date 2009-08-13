From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless-2.6 2009-08-11
Date: Wed, 12 Aug 2009 17:38:42 -0700 (PDT)
Message-ID: <20090812.173842.227384033.davem@davemloft.net>
References: <20090811183605.GG2634@tuxdriver.com>
	<20090812182403.GF2657@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47981
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750866AbZHMAic (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2009 20:38:32 -0400
In-Reply-To: <20090812182403.GF2657@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "John W. Linville" <linville@tuxdriver.com>
Date: Wed, 12 Aug 2009 14:24:03 -0400

> When you pull this, could you also revert 57921c31 ("libertas: Read
> buffer overflow").  It has been shown to create a new problem.  There
> is work towards a solution to that one, but it isn't a simple clean-up.

Done.
