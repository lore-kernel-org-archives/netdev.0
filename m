From: David Miller <davem@davemloft.net>
Subject: net-2.6 merged into net-next-2.6
Date: Fri, 17 Dec 2010 13:03:28 -0800 (PST)
Message-ID: <20101217.130328.115937277.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39444
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755351Ab0LQVC7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Dec 2010 16:02:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I just did a merge, it was mostly clean except for some
wireless bits (some -next work conflicted with the recent
"use_new_eeprom_foo" changes in iwlwifi).

John please take a quick look and see if I made any mistakes.

Thanks.
