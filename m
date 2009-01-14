From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] hso_spinlockfix.patch
Date: Wed, 14 Jan 2009 02:08:57 -0800 (PST)
Message-ID: <20090114.020857.00093874.davem@davemloft.net>
References: <496DB66B.4070306@option.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: D.Barow@option.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51748
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750707AbZANKI4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 05:08:56 -0500
In-Reply-To: <496DB66B.4070306@option.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Denis Joseph Barrow <D.Barow@option.com>
Date: Wed, 14 Jan 2009 10:54:51 +0100

> This is a really important fix it fixes a consistent kernel deadlock
> when the hso driver starts going. It's against 2.6.29-rc1, 2.6.29-rc6
> worked fine.

Are you able to travel in time? :-)  2.6.29-rc6 has not been
released yet.
