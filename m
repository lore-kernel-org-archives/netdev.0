From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] pppoe: Lacks DST MAC address check
Date: Mon, 20 Apr 2015 14:11:58 -0400 (EDT)
Message-ID: <20150420.141158.32627615256852547.davem@davemloft.net>
References: <1429350794-17170-1-git-send-email-Joakim.Tjernlund@transmode.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Joakim.Tjernlund@transmode.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46025 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751865AbbDTSL7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Apr 2015 14:11:59 -0400
In-Reply-To: <1429350794-17170-1-git-send-email-Joakim.Tjernlund@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Date: Sat, 18 Apr 2015 11:53:14 +0200

> A pppoe session is identified by its session ID and MAC address.
> Currently pppoe does not check if the received pkg has the correct
> MAC address. This is a problem when the eth I/F is in promisc mode
> as then any DST MAC address is accepted.

Please read Documentation/SubmittingPatches in the source tree, you
need to provide a proper signoff.
