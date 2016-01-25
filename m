From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 2/4] lan78xx: replace devid to chipid & chiprev
Date: Mon, 25 Jan 2016 15:27:29 -0800 (PST)
Message-ID: <20160125.152729.132746793740931912.davem@davemloft.net>
References: <9235D6609DB808459E95D78E17F2E43D4049DED4@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Woojung.Huh@microchip.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52623 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932544AbcAYX1d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jan 2016 18:27:33 -0500
In-Reply-To: <9235D6609DB808459E95D78E17F2E43D4049DED4@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Such cleanups are not appropriate for the 'net' tree.

And the 'net-next' tree is closed.

You _MUST_ separate out the pure bug fixes and submit only those
changes targetting the 'net' tree.

You must learn how to submit changes properly.
