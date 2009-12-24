From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 2/3] be2net: Bug fix to config NIC
 appropriately before loopback test
Date: Wed, 23 Dec 2009 20:58:55 -0800 (PST)
Message-ID: <20091223.205855.212678858.davem@davemloft.net>
References: <20091223144134.GA23401@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sarveshwarb@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56377
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756303AbZLXE6x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2009 23:58:53 -0500
In-Reply-To: <20091223144134.GA23401@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sarveshwar Bandi <sarveshwarb@serverengines.com>
Date: Wed, 23 Dec 2009 20:11:44 +0530

> NIC controller has to be set to an appropriate mode before doing a loopback 
> test. Test will fail otherwise.
> 
> Signed-off-by: Sarveshwar Bandi <sarveshwarb@serverengines.com>

Applied.
