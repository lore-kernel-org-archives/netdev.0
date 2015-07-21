From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] cxgb4 DCB updates
Date: Tue, 21 Jul 2015 00:23:38 -0700 (PDT)
Message-ID: <20150721.002338.229420322213404581.davem@davemloft.net>
References: <1437163953-15447-1-git-send-email-anish@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hariprasad@chelsio.com
To: anish@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56094 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752968AbbGUHXj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2015 03:23:39 -0400
In-Reply-To: <1437163953-15447-1-git-send-email-anish@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anish Bhatt <anish@chelsio.com>
Date: Fri, 17 Jul 2015 13:12:29 -0700

> The following patchset covers changes to work better with  the userspace
> tools cgdcbxd and cgrulesengd and improves firmware support for
> host-managed mode.
> 
> Also exports traffic class information that was previously not being
> exported via dcbnl_ops and unfifies how app selector information is passed
> to firmware.

Series applied, thank you.
