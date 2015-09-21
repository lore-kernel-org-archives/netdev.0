From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] geneve: remove vlan-related feature assignment
Date: Mon, 21 Sep 2015 16:24:50 -0700 (PDT)
Message-ID: <20150921.162450.633512210683384807.davem@davemloft.net>
References: <1442510338-10180-1-git-send-email-linville@tuxdriver.com>
	<1442607632-16580-1-git-send-email-linville@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pshelar@nicira.com, jesse@nicira.com
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56385 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756198AbbIUXYv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2015 19:24:51 -0400
In-Reply-To: <1442607632-16580-1-git-send-email-linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "John W. Linville" <linville@tuxdriver.com>
Date: Fri, 18 Sep 2015 16:20:32 -0400

> The code handling vlan tag insertion was dropped in commit 371bd1061d29
> ("geneve: Consolidate Geneve functionality in single module.").  Now we
> need to drop the related vlan feature bits in the netdev structure.
> 
> Signed-off-by: John W. Linville <linville@tuxdriver.com>

Applied, thanks.
