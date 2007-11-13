From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/13] tg3: APE flag fix
Date: Mon, 12 Nov 2007 21:09:14 -0800 (PST)
Message-ID: <20071112.210914.207262021.davem@davemloft.net>
References: <1194655123.5745.265.camel@teletran1>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mchan@broadcom.com
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44140
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750959AbXKMFJP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2007 00:09:15 -0500
In-Reply-To: <1194655123.5745.265.camel@teletran1>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Fri, 09 Nov 2007 16:38:43 -0800

> This patch corrects a bug where the ENABLE_APE flag was tested against
> the wrong flag variable.
> 
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Good catch, patch applied.  Thanks Matt.
