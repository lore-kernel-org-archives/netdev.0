From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: r8169: convert to hw_features
Date: Wed, 20 Apr 2011 12:25:50 -0700 (PDT)
Message-ID: <20110420.122550.200350710.davem@davemloft.net>
References: <20110418180857.GB18469@electric-eye.fr.zoreil.com>
	<20110418.225400.189709717.davem@davemloft.net>
	<20110420191336.GB18805@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dave@thedillows.org, netdev@vger.kernel.org, nic_swsd@realtek.com
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41697
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755672Ab1DTT0Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2011 15:26:25 -0400
In-Reply-To: <20110420191336.GB18805@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Wed, 20 Apr 2011 21:13:36 +0200

> David Miller <davem@davemloft.net> :
> [...]
>> Maybe we can progressively start to try and turn these things on
>> by default now that we know more about the TX descriptor layout
>> differences.
> 
> Sure. I'd welcome a little timeslot to push a few configuration and
> cosmetic things though.

No problem.
