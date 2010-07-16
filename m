From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/6] vxge: Fix multicast issues
Date: Thu, 15 Jul 2010 20:50:46 -0700 (PDT)
Message-ID: <20100715.205046.68121349.davem@davemloft.net>
References: <1279219648-10345-2-git-send-email-jon.mason@exar.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sreenivasa.honnur@exar.com,
	ramkrishna.vepa@exar.com
To: jon.mason@exar.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60720
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934092Ab0GPDua (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jul 2010 23:50:30 -0400
In-Reply-To: <1279219648-10345-2-git-send-email-jon.mason@exar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Mason <jon.mason@exar.com>
Date: Thu, 15 Jul 2010 13:47:24 -0500

> Fix error in multicast flag check, add calls to restore the status of
> multicast and promiscuous mode settings after change_mtu, and style
> cleanups to shorten the function calls by using a temporary variable.
> 
> Signed-off-by: Jon Mason <jon.mason@exar.com>
> Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@exar.com>
> Signed-off-by: Ramkrishna Vepa <ramkrishna.vepa@exar.com>

Applied.
