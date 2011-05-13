From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv3 net-next-2.6 1/3] qlcnic: FW dump support
Date: Fri, 13 May 2011 14:44:29 -0400 (EDT)
Message-ID: <20110513.144429.1444633847309533046.davem@davemloft.net>
References: <1305240515-29237-1-git-send-email-anirban.chakraborty@qlogic.com>
	<1305240515-29237-3-git-send-email-anirban.chakraborty@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com
To: anirban.chakraborty@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50592 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754777Ab1EMSof (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2011 14:44:35 -0400
In-Reply-To: <1305240515-29237-3-git-send-email-anirban.chakraborty@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Date: Thu, 12 May 2011 15:48:33 -0700

> Added code to take FW dump.
> o Driver queries FW at the init time and gets the dump template
> o It takes FW dump as per the dump template
> o Level of FW dump (and its size) is configured via dump flag
> 
> Signed-off-by: Sritej Velaga <sritej.velaga@qlogic.com>
> Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>

Applied.
