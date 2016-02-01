From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v4] r8169: Added delay after power on and reset.
Date: Mon, 01 Feb 2016 11:40:18 -0800 (PST)
Message-ID: <20160201.114018.1498149920155555854.davem@davemloft.net>
References: <1454342720-2020-1-git-send-email-asd@marian1000.go.ro>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: asd@marian1000.go.ro
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41786 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753300AbcBATkT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Feb 2016 14:40:19 -0500
In-Reply-To: <1454342720-2020-1-git-send-email-asd@marian1000.go.ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Corcodel Marian <asd@marian1000.go.ro>
Date: Mon,  1 Feb 2016 18:05:20 +0200

> On reset and power on need 2msecs delay to autoload complete data
>  from eeprom to VPD.
> 
> Signed-off-by: Corcodel Marian <asd@marian1000.go.ro>

Where is this needed delay documented?

Unless you are a Realtek engineer, or learned about the requirement
from them, I want to see the HW document that explains this.
