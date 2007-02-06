From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tg3 : avoid an expensive divide
Date: Tue, 06 Feb 2007 14:17:56 -0800 (PST)
Message-ID: <20070206.141756.62663615.davem@davemloft.net>
References: <200702061536.18800@nienna>
	<20070206.114659.107250775.davem@davemloft.net>
	<45C8EAC4.9020803@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36034
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965541AbXBFWSW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Feb 2007 17:18:22 -0500
In-Reply-To: <45C8EAC4.9020803@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Eric, I've applied your patch as-is to net-2.6.21, thanks.
