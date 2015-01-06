From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] Driver: Vmxnet3: Make Rx ring 2 size
 configurable
Date: Tue, 06 Jan 2015 14:15:31 -0500 (EST)
Message-ID: <20150106.141531.1937050067918707190.davem@davemloft.net>
References: <1420564815-32101-1-git-send-email-skhare@vmware.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sbhatewara@vmware.com, pv-drivers@vmware.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	bollar@vmware.com
To: skhare@vmware.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53062 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753405AbbAFTPd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 14:15:33 -0500
In-Reply-To: <1420564815-32101-1-git-send-email-skhare@vmware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shrikrishna Khare <skhare@vmware.com>
Date: Tue,  6 Jan 2015 09:20:15 -0800

> Rx ring 2 size can be configured by adjusting rx-jumbo parameter
> of ethtool -G.
> 
> Signed-off-by: Ramya Bolla <bollar@vmware.com>
> Signed-off-by: Shreyas Bhatewara <sbhatewara@vmware.com>
> Signed-off-by: Shrikrishna Khare <skhare@vmware.com>

Applied, thanks.
