From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] bnx2x: resurrect RX hashing
Date: Fri, 26 Aug 2011 12:51:17 -0400 (EDT)
Message-ID: <20110826.125117.269418223701648517.davem@davemloft.net>
References: <20110823161530.24707.67923.stgit@dhcp-29-224.brq.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vladz@broadcom.com, eilong@broadcom.com,
	dmitry@broadcom.com, mirq-linux@rere.qmqm.pl
To: mschmidt@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58632 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755391Ab1HZQvY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Aug 2011 12:51:24 -0400
In-Reply-To: <20110823161530.24707.67923.stgit@dhcp-29-224.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Schmidt <mschmidt@redhat.com>
Date: Tue, 23 Aug 2011 18:15:32 +0200

> bnx2x used to be able to set rxhash, but this was lost in the conversion
> to hw_features (commit 66371c441).
> Restore it and enable it by default.
> 
> Signed-off-by: Michal Schmidt <mschmidt@redhat.com>

Applied.
