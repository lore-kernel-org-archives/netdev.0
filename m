From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] dsa: correctly determine the number of switches in a
 system
Date: Sat, 07 Feb 2015 22:08:15 -0800 (PST)
Message-ID: <20150207.220815.202107243716658102.davem@davemloft.net>
References: <20150205135409.GB29383@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tobias@waldekranz.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46762 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751577AbbBHGIP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Feb 2015 01:08:15 -0500
In-Reply-To: <20150205135409.GB29383@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Waldekranz <tobias@waldekranz.com>
Date: Thu, 5 Feb 2015 14:54:09 +0100

> The number of connected switches was sourced from the number of
> children to the DSA node, change it to the number of available
> children, skipping any disabled switches.
> 
> Signed-off-by: Tobias Waldekranz <tobias@waldekranz.com>

Applied.
