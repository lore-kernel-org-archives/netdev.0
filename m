From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/3] Add size table feature for qdiscs
Date: Sun, 20 Jul 2008 00:09:50 -0700 (PDT)
Message-ID: <20080720.000950.96686337.davem@davemloft.net>
References: <20080719233441.12596.91242.stgit@fate.lan>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: jussi.kivilinna@mbnet.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38819
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751767AbYGTHJu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jul 2008 03:09:50 -0400
In-Reply-To: <20080719233441.12596.91242.stgit@fate.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Date: Sun, 20 Jul 2008 02:34:55 +0300

> Patch adds generic size table for qdiscs that is similiar to rate table
> used by htb/tbf/cbq.
> 
> Changes since v1:
>  - ingress qdisc / actions handled too
>  - size of table is now dynamic
>  - add qdisc_enqueue_root wrapper

This stuff looks fundamentally fine to me, so I've added
these changes to net-2.6

Please send any further fixups as relative changes.

Thanks.
