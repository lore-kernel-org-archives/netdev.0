From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 1/3] be2net: Bug fix to avoid soft lockup in
 loopback test.
Date: Wed, 23 Dec 2009 20:58:43 -0800 (PST)
Message-ID: <20091223.205843.200363619.davem@davemloft.net>
References: <20091223144026.GA23383@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sarveshwarb@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56374
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752561AbZLXE6l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2009 23:58:41 -0500
In-Reply-To: <20091223144026.GA23383@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sarveshwar Bandi <sarveshwarb@serverengines.com>
Date: Wed, 23 Dec 2009 20:10:36 +0530

> This change ensures that loopback test command gives up after 4 seconds when 
> the hardware is not responsive. This could happen if the ports are connected 
> properly in loopback mode.
> 
> Signed-off-by: Sarveshwar Bandi <sarveshwarb@serverengines.com>

Applied.
