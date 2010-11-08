From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] solos: Add 'Firmware' attribute for Traverse
 overall firmware version
Date: Mon, 08 Nov 2010 12:18:21 -0800 (PST)
Message-ID: <20101108.121821.226769105.davem@davemloft.net>
References: <1288643669.5977.21.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dwmw2@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43036
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753179Ab0KHUR6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Nov 2010 15:17:58 -0500
In-Reply-To: <1288643669.5977.21.camel@macbook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Woodhouse <dwmw2@infradead.org>
Date: Mon, 01 Nov 2010 16:34:29 -0400

> The existing 'FirmwareVersion' attribute only covers the DSP firmware as
> provided by Conexant; not the overall version of the device firmware. We
> do want to be able to see the full version number too.
> 
> Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>

Applied.
