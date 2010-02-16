From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] be2net: set proper value to version field in
 req hdr
Date: Tue, 16 Feb 2010 15:15:26 -0800 (PST)
Message-ID: <20100216.151526.222249400.davem@davemloft.net>
References: <20100216101749.GA9465@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ajitk@serverengines.com, ajitkhaparde@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55496
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933531Ab0BPXPL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2010 18:15:11 -0500
In-Reply-To: <20100216101749.GA9465@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ajit Khaparde <ajitkhaparde@gmail.com>
Date: Tue, 16 Feb 2010 15:48:46 +0530

> Before sending a command to the ASIC, set version properly.
> This is necessary for the ARM firmware to send correct data to the driver.
> This also fixes a bug in certain skews of the ASIC where the statistics
> are misreported.
> 
> Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>

Applied.
