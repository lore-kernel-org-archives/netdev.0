From: David Miller <davem@davemloft.net>
Subject: Re: [PACH] smsc911x: replace manual phy lookup.
Date: Wed, 17 Feb 2010 16:03:14 -0800 (PST)
Message-ID: <20100217.160314.133753808.davem@davemloft.net>
References: <20100217075458.GA4388@coldcone>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steve.glendinning@smsc.com, jpirko@redhat.com,
	netdev@vger.kernel.org
To: "kirjanov@gmail.com"@sunset.davemloft.net.davemloft.net,
	kirjanov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42069
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758009Ab0BRAC7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2010 19:02:59 -0500
In-Reply-To: <20100217075458.GA4388@coldcone>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Denis Kirjanov <kirjanov@gmail.com" <kirjanov@gmail.com>
Date: Wed, 17 Feb 2010 10:54:58 +0300

> Use phy_find_first() function instead of manual lookup.
> 
> Signed-off-by: Denis Kirjanov <kirjanov@gmail.com>

Applied.
