From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 7/13] tg3: Disable GPHY autopowerdown
Date: Mon, 12 Nov 2007 21:16:31 -0800 (PST)
Message-ID: <20071112.211631.108120050.davem@davemloft.net>
References: <1194655134.5745.269.camel@teletran1>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mchan@broadcom.com
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45635
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750710AbXKMFQb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2007 00:16:31 -0500
In-Reply-To: <1194655134.5745.269.camel@teletran1>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Fri, 09 Nov 2007 16:38:54 -0800

> New CPMU devices contend with the GPHY for power management.  The GPHY
> autopowerdown feature is enabled by default in the PHY and thus needs to
> be disabled after every PHY reset.
> 
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Patch applied, thanks.
