From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 0/3] net: stmmac: Enable Intel Quark SoC X1000
 Ethernet support
Date: Tue, 27 Jan 2015 21:08:30 -0800 (PST)
Message-ID: <20150127.210830.880862918225307128.davem@davemloft.net>
References: <1422387889-21559-1-git-send-email-andriy.shevchenko@linux.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org
To: andriy.shevchenko@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55380 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761441AbbA1FIe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2015 00:08:34 -0500
In-Reply-To: <1422387889-21559-1-git-send-email-andriy.shevchenko@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Date: Tue, 27 Jan 2015 21:44:46 +0200

> This is third version of the patch series [1] to bring network card support to
> Intel Quark SoC.
> 
> The series has been tested on Intel Galileo board.
> 
> Changelog v3:
>  - rebase on top of recent net-next
>  - rework an approach to get the custom configuration
>  - rework an approach how to get unique bus_id
>  - improve DMI lookup function
> 
> [1] http://www.spinics.net/lists/netdev/msg296010.html

Series applied, thanks.
