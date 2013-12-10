From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] PF_PACKET updates
Date: Mon, 09 Dec 2013 20:24:05 -0500 (EST)
Message-ID: <20131209.202405.918440581801459446.davem@davemloft.net>
References: <1386326177-4483-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, brouer@redhat.com
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44820 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750927Ab3LJBYG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Dec 2013 20:24:06 -0500
In-Reply-To: <1386326177-4483-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Fri,  6 Dec 2013 11:36:14 +0100

> Patch descriptions in individual patches.
> 
> In order to avoid a possible merge conflict, we suggest to take
> the first patch through net tree, merge net into net-next and
> apply the remaining two patches on top of it. Dave, please let
> us know if you like to handle this differently than suggested.
> 
> For patch 3 we'll send a man-page update as a follow-up.

Patch #1 applied to 'net' and queued up for -stable.

Patch #2 and #3 applied to 'net-next'.

Thanks!
