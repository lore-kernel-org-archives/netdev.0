From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 06/15] tg3: Do not enable APE on bcm5700
Date: Mon, 03 Nov 2008 16:52:39 -0800 (PST)
Message-ID: <20081103.165239.196971697.davem@davemloft.net>
References: <1225751622.6181@xw6200>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com, andy@greyhouse.net
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38260
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755100AbYKDAxD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2008 19:53:03 -0500
In-Reply-To: <1225751622.6181@xw6200>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Mon, 3 Nov 2008 02:12:05 -0800

> With older versions of the NVRAM format, the driver may mistakenly
> determine that APE is enabled.  Make sure this doesn't happen by
> restricting the ENABLE_APE check to devices known to have more
> recent NVRAM image formats.
> 
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
