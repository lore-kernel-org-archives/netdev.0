From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sctp: convert sack_needed and sack_generation to bits
Date: Wed, 02 Dec 2015 23:40:01 -0500 (EST)
Message-ID: <20151202.234001.1035831453332214345.davem@davemloft.net>
References: <f3803545e5d34adfe83cff5adf01317c56288d59.1448892562.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vyasevich@gmail.com, nhorman@tuxdriver.com,
	linux-sctp@vger.kernel.org, lucien.xin@gmail.com
To: marcelo.leitner@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58949 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753942AbbLCEkD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2015 23:40:03 -0500
In-Reply-To: <f3803545e5d34adfe83cff5adf01317c56288d59.1448892562.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Date: Mon, 30 Nov 2015 12:17:06 -0200

> They don't need to be any bigger than that and with this we start a new
> bitfield for tracking association runtime stuff, like zero window
> situation.
> 
> Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

Applied.
