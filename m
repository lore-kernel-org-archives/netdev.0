From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/5] cxgb4 : Add DCBx support to Chelsio
 cxgb4 driver
Date: Sun, 22 Jun 2014 21:14:41 -0700 (PDT)
Message-ID: <20140622.211441.1814977096261918651.davem@davemloft.net>
References: <1403239035-10771-1-git-send-email-anish@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leedom@chelsio.com, hariprasad@chelsio.com
To: anish@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50682 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750719AbaFWEOp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2014 00:14:45 -0400
In-Reply-To: <1403239035-10771-1-git-send-email-anish@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anish Bhatt <anish@chelsio.com>
Date: Thu, 19 Jun 2014 21:37:10 -0700

> v2 : move inclusion of struct port_dcb_info to the same patch as where it is defined.

Put this changelog information after your description, not before.

>     This patchset adds support for DCBx via dcbnl_ops to the cxgb4 driver. This should enable cxgb4 to work with open-lldp and the like. The last patch only updates copyright year.

Please format your commit message so that lines are no longer than 80
columns in length.

Series applied, thanks.
