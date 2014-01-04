From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] llc: make lock static
Date: Fri, 03 Jan 2014 20:57:05 -0500 (EST)
Message-ID: <20140103.205705.513360043361326733.davem@davemloft.net>
References: <20140103091951.06153029@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35753 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754501AbaADB5H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jan 2014 20:57:07 -0500
In-Reply-To: <20140103091951.06153029@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Fri, 3 Jan 2014 09:19:51 -0800

> The llc_sap_list_lock does not need to be global, only acquired
> in core.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Applied.
