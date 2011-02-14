From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless-2.6 2011-02-14
Date: Mon, 14 Feb 2011 13:28:05 -0800 (PST)
Message-ID: <20110214.132805.48509966.davem@davemloft.net>
References: <20110214.125148.59672184.davem@davemloft.net>
	<20110214.130056.115934219.davem@davemloft.net>
	<1297717942.3953.9.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38331
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750844Ab1BNV13 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Feb 2011 16:27:29 -0500
In-Reply-To: <1297717942.3953.9.camel@jlt3.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Mon, 14 Feb 2011 22:12:22 +0100

> On Mon, 2011-02-14 at 13:00 -0800, David Miller wrote:
> 
>> Please address this newly introduced warning in a future pull request,
>> thanks:
>> 
>> drivers/net/wireless/iwlwifi/iwl-3945.c:411:13: warning: 'iwl3945_good_plcp_health' defined but not used
> 
> The function can simply be deleted.

Done.
