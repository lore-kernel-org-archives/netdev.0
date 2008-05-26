From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 8/8] tg3: Update version to 3.93
Date: Sun, 25 May 2008 23:53:11 -0700 (PDT)
Message-ID: <20080525.235311.235732094.davem@davemloft.net>
References: <1211511433.0@teletran1>
	<20080525.235115.264290985.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com, benli@broadcom.com,
	andy@greyhouse.net
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46072
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752720AbYEZGxP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 May 2008 02:53:15 -0400
In-Reply-To: <20080525.235115.264290985.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Matt, don't we need a PHYLIB dependency or select statement for the
tg3 driver option in drivers/net/Kconfig now?
