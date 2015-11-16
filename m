From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] Driver: Vmxnet3: Fix use of mfTableLen for
 big endian architectures
Date: Mon, 16 Nov 2015 15:06:34 -0500 (EST)
Message-ID: <20151116.150634.1258914853943067233.davem@davemloft.net>
References: <1447458130-31985-1-git-send-email-skhare@vmware.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	pv-drivers@vmware.com, uebayasi@gmail.com, bhavesh@vmware.com
To: skhare@vmware.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40777 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750982AbbKPUGg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2015 15:06:36 -0500
In-Reply-To: <1447458130-31985-1-git-send-email-skhare@vmware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shrikrishna Khare <skhare@vmware.com>
Date: Fri, 13 Nov 2015 15:42:10 -0800

> Signed-off-by: Shrikrishna Khare <skhare@vmware.com>
> Reported-by: Masao Uebayashi <uebayasi@gmail.com>
> Signed-off-by: Bhavesh Davda <bhavesh@vmware.com>

You guys really have to stop targetting simple, straightforward,
bug fixes at net-next.  That is not appropriate.

Bug fixes should target 'net'.
