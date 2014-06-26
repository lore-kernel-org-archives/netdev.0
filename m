From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tipc: bump max configurable window size
Date: Wed, 25 Jun 2014 18:03:55 -0700 (PDT)
Message-ID: <20140625.180355.1366015617138192483.davem@davemloft.net>
References: <1403683625-30136-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net
To: erik.hugne@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39741 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755235AbaFZBD4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2014 21:03:56 -0400
In-Reply-To: <1403683625-30136-1-git-send-email-erik.hugne@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <erik.hugne@ericsson.com>
Date: Wed, 25 Jun 2014 10:07:05 +0200

> From: Erik Hugne <erik.hugne@ericsson.com>
> 
> The maximum window size is limited by the sequence gap field, which
> was expanded with bd7845337b105e090dd18912d511139945fa7586
> ("tipc: Expand link sequence gap field to 13 bits")
> We remove the artificial limit that prevents the link window to be
> set larger than 150.
> 
> Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
> Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>

Applied, thanks.
