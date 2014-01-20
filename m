From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] phy: cleanup 10g code
Date: Sun, 19 Jan 2014 19:56:13 -0800 (PST)
Message-ID: <20140119.195613.55693159151305701.davem@davemloft.net>
References: <20140119114820.028fa940@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: afleming@gmail.com, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41079 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752757AbaATD4O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jan 2014 22:56:14 -0500
In-Reply-To: <20140119114820.028fa940@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Sun, 19 Jan 2014 11:48:20 -0800

> Code should avoid needless exports, don't export something unless it used.
> Make local functions static and remove unused stubs.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Applied.
