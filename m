From: David Miller <davem@davemloft.net>
Subject: Re: Bluetooth update for 2.6
Date: Fri, 07 Jul 2006 00:17:45 -0700 (PDT)
Message-ID: <20060707.001745.07431025.davem@davemloft.net>
References: <1152216560.20938.37.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:21678
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751263AbWGGHR3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Jul 2006 03:17:29 -0400
To: marcel@holtmann.org
In-Reply-To: <1152216560.20938.37.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Marcel Holtmann <marcel@holtmann.org>
Date: Thu, 06 Jul 2006 22:09:20 +0200

> this is the second part of pending updates of the Bluetooth subsystem
> for the upcoming 2.6.18 kernel. A couple of them are only coding style
> cleanups which I failed to submit for the previous kernel release. They
> slipped somehow. The rest is driver model integration stuff. Please push
> them to Linus as soon as possible.

The merge window for 2.6.18 is closed, so you will need to eliminate
things like code cleanups and other non-bugfixes.
