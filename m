From: David Miller <davem@davemloft.net>
Subject: Re: Conflict when compiling-in CONFIG_FIXED_PHY
Date: Wed, 08 Sep 2010 13:15:30 -0700 (PDT)
Message-ID: <20100908.131530.102534511.davem@davemloft.net>
References: <AANLkTi=J0gUzcj2O_MNCj=X-ZdgXgxG_ED57L7YQM+z9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: amit.kucheria@verdurent.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47560
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753608Ab0IHUPM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Sep 2010 16:15:12 -0400
In-Reply-To: <AANLkTi=J0gUzcj2O_MNCj=X-ZdgXgxG_ED57L7YQM+z9@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amit Kucheria <amit.kucheria@verdurent.com>
Date: Wed, 8 Sep 2010 23:13:16 +0300

> I am not sure what the real fix should be - to prevent compiling-in of
> FIXED_PHY with such drivers in Kconfig or a smarter mechanism to
> assign the bus id (idr?).

Some better assignment is probably the best.
