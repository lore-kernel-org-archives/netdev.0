From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 2/2] tipc: pskb_copy() buffers when sending on more
 than one bearer
Date: Mon, 29 Apr 2013 15:45:08 -0400 (EDT)
Message-ID: <20130429.154508.249973141135574888.davem@davemloft.net>
References: <1367244820-29881-1-git-send-email-gerlando.falauto@keymile.com>
	<1367244820-29881-2-git-send-email-gerlando.falauto@keymile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jon.maloy@ericsson.com,
	erik.hugne@ericsson.com, ying.xue@windriver.com,
	holger.brunck@keymile.com
To: gerlando.falauto@keymile.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33951 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761030Ab3D2TpK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Apr 2013 15:45:10 -0400
In-Reply-To: <1367244820-29881-2-git-send-email-gerlando.falauto@keymile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


You'll need to respin and resubmit this when you fix the problems
in the first patch.
