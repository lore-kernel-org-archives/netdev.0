From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] mac802154: llsec: add forgotten list_del_rcu
 in key removal
Date: Fri, 06 Jun 2014 16:26:03 -0700 (PDT)
Message-ID: <20140606.162603.32070373535076895.davem@davemloft.net>
References: <1402057672-17657-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-zigbee-devel@lists.sourceforge.net
To: phoebe.buckheister@itwm.fraunhofer.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32959 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752333AbaFFX0E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jun 2014 19:26:04 -0400
In-Reply-To: <1402057672-17657-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
Date: Fri,  6 Jun 2014 14:27:52 +0200

> During key removal, the key object is freed, but not taken out of the
> llsec key list properly. Fix that.
> 
> Signed-off-by: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>

Applied, thank you.
