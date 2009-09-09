From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [IB] 2.6.31-rc9: SW2HW_EQ failed on Dell R610
Date: Wed, 9 Sep 2009 10:02:29 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0909091001450.28070@V090114053VZO-1>
References: <alpine.DEB.1.10.0909081805110.7733@V090114053VZO-1> <ada1vmgn76v.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.ultrahosting.com ([74.213.174.253]:60759 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752521AbZIIODc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2009 10:03:32 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 2F5DE82C389
	for <netdev@vger.kernel.org>; Wed,  9 Sep 2009 10:04:30 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id IqKrTLYBopPm for <netdev@vger.kernel.org>;
	Wed,  9 Sep 2009 10:04:24 -0400 (EDT)
Received: from V090114053VZO-1 (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 9388482C2F1
	for <netdev@vger.kernel.org>; Wed,  9 Sep 2009 10:04:24 -0400 (EDT)
In-Reply-To: <ada1vmgn76v.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 8 Sep 2009, Roland Dreier wrote:

> The workaround of limiting possible cpus to 16 should be OK for the time
> between 2.6.31 and 2.6.31.1.

Why not merge it immediately? Dell R610s are fairly standard.

