From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] sctp: Updates and fixes
Date: Mon, 16 Feb 2009 00:07:16 -0800 (PST)
Message-ID: <20090216.000716.118829405.davem@davemloft.net>
References: <1234550024-30915-1-git-send-email-vladislav.yasevich@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38917
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754576AbZBPIHc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Feb 2009 03:07:32 -0500
In-Reply-To: <1234550024-30915-1-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Fri, 13 Feb 2009 13:33:40 -0500

> Here are some updates and fixes for SCTP:
>     - Allow disabling of checksum with a module parameter.
>     - Cleanup the sctp checksum code to get rid of excessive casts
>     - Fix the exponention RTO update with Heartbeats.
>     - Preserve socket level options on accept/peeloff.

All applied, thanks Vlad.
