From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/6] bna: Tx and Rx Redesign
Date: Mon, 01 Aug 2011 18:09:59 -0700 (PDT)
Message-ID: <20110801.180959.434819216427342007.davem@davemloft.net>
References: <1312231375-14398-1-git-send-email-rmody@brocade.com>
	<1312231375-14398-7-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, adapter_linux_open_src_team@brocade.com
To: rmody@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39885 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752466Ab1HBBLB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Aug 2011 21:11:01 -0400
In-Reply-To: <1312231375-14398-7-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This just adds a lot of new code, but there are no users of this
new code.

Resubmit this when you have the actual users of the code ready.

I'm not applying this entire patch series.
