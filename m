From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] Driver: Vmxnet3: Copy TCP header to mapped
 frame for IPv6 packets
Date: Sun, 01 Mar 2015 23:04:09 -0500 (EST)
Message-ID: <20150301.230409.1625950995148478792.davem@davemloft.net>
References: <1425184389-29481-1-git-send-email-skhare@vmware.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sbhatewara@vmware.com, pv-drivers@vmware.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	banerjeea@vmware.com
To: skhare@vmware.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46326 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753106AbbCBEEK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Mar 2015 23:04:10 -0500
In-Reply-To: <1425184389-29481-1-git-send-email-skhare@vmware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shrikrishna Khare <skhare@vmware.com>
Date: Sat, 28 Feb 2015 20:33:09 -0800

> Allows for packet parsing to be done by the fast path. This performance
> optimization already exists for IPv4. Add similar logic for IPv6.
> 
> Signed-off-by: Amitabha Banerjee <banerjeea@vmware.com>
> Signed-off-by: Shrikrishna Khare <skhare@vmware.com>

Applied, thanks.
