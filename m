From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: amd-xgbe: Add hardware dependency
Date: Sat, 09 May 2015 16:24:43 -0400 (EDT)
Message-ID: <20150509.162443.1552565670304789745.davem@davemloft.net>
References: <20150506090440.15fb1eef@endymion.delvare>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, thomas.lendacky@amd.com,
	f.fainelli@gmail.com
To: jdelvare@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45175 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750951AbbEIUYp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2015 16:24:45 -0400
In-Reply-To: <20150506090440.15fb1eef@endymion.delvare>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jean Delvare <jdelvare@suse.de>
Date: Wed, 6 May 2015 09:04:40 +0200

> The amd-xgbe driver currently only works with the Seattle SoC, which
> is ARM64 architecture, so there is no point in building this driver on
> other architectures except for build testing purpose. The dependency
> list can be updated later if the driver ever supports other
> architectures.
> 
> Signed-off-by: Jean Delvare <jdelvare@suse.de>

Applied.
