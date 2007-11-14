From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.24 1/1]S2io: Support for add/delete/store/restore
 ethernet addresses
Date: Wed, 14 Nov 2007 12:03:59 -0800 (PST)
Message-ID: <20071114.120359.21994235.davem@davemloft.net>
References: <20071114.014324.78802691.davem@davemloft.net>
	<78C9135A3D2ECE4B8162EBDCE82CAD770289B951@nekter>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Sreenivasa.Honnur@neterion.com, netdev@vger.kernel.org,
	jeff@garzik.org, support@neterion.com
To: Ramkrishna.Vepa@neterion.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50783
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754687AbXKNUEI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 15:04:08 -0500
In-Reply-To: <78C9135A3D2ECE4B8162EBDCE82CAD770289B951@nekter>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com>
Date: Wed, 14 Nov 2007 11:47:34 -0500

> Scheduling for the 2.6.25 merge window is fine. Curious - why did you
> have to remove the driver version? We use it to keep track of our
> changes submitted.

Because it conflicted with the driver version bump you did
for the MSI-X leak bug fix.
