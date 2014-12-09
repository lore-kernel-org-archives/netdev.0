From: David Miller <davem@davemloft.net>
Subject: Re: [net-next v2 00/16][pull request] Intel Wired LAN Driver
 Updates 2014-12-06
Date: Mon, 08 Dec 2014 20:50:31 -0500 (EST)
Message-ID: <20141208.205031.1761143065244503062.davem@davemloft.net>
References: <1417870933-17248-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59223 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753206AbaLIBuf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2014 20:50:35 -0500
In-Reply-To: <1417870933-17248-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Sat,  6 Dec 2014 05:01:57 -0800

> This series contains updates to i40e and i40evf.

Pulled, thanks Jeff.

Please take into consideration Joe Perches's feedback to use static
inlines instead of macros.

Thanks.
