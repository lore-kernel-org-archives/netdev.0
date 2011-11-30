From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sky2: add bql support
Date: Tue, 29 Nov 2011 20:55:12 -0500 (EST)
Message-ID: <20111129.205512.1293424878350457408.davem@davemloft.net>
References: <20111128201907.6d31d4c3@nehalam.linuxnetplumber.net>
	<20111129171533.146cec9f@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:45730 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754661Ab1K3BzS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2011 20:55:18 -0500
In-Reply-To: <20111129171533.146cec9f@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 29 Nov 2011 17:15:33 -0800

> This adds support for byte queue limits and aggregates statistics
> update (suggestion from Eric).
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
