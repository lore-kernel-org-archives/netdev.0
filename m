From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v3 0/8] tc offload for cls_u32 on ixgbe
Date: Wed, 17 Feb 2016 09:48:04 -0500 (EST)
Message-ID: <20160217.094804.2116619701024963115.davem@davemloft.net>
References: <20160217051418.17139.41052.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, amir@vadai.me, jhs@mojatatu.com,
	netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com
To: john.fastabend@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52684 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423553AbcBQOsI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 09:48:08 -0500
In-Reply-To: <20160217051418.17139.41052.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.fastabend@gmail.com>
Date: Tue, 16 Feb 2016 21:15:50 -0800

> This extends the setup_tc framework so it can support more than just
> the mqprio offload and push other classifiers and qdiscs into the
> hardware.

Series applied, thanks John!
