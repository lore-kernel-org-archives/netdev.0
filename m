From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next stable v2] sctp: fully initialize sctp_outq in
 sctp_outq_init
Date: Thu, 13 Jun 2013 02:44:53 -0700 (PDT)
Message-ID: <20130613.024453.1256276769178191648.davem@davemloft.net>
References: <1371061604-27312-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org, sergei.shtylyov@cogentembedded.com,
	vyasevich@gmail.com, netdev@vger.kernel.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38540 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755203Ab3FMJoy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jun 2013 05:44:54 -0400
In-Reply-To: <1371061604-27312-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


'net-next' + 'stable' is an invalid set of targets for a patch.

If the patch is appropriate for 'stable', then it had better be
appropriate for plain 'net' as well.
