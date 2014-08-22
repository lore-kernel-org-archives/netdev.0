From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] SCTP fix
Date: Fri, 22 Aug 2014 11:31:51 -0700 (PDT)
Message-ID: <20140822.113151.962878833082075340.davem@davemloft.net>
References: <1408705410-28558-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52953 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932410AbaHVSbw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2014 14:31:52 -0400
In-Reply-To: <1408705410-28558-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Fri, 22 Aug 2014 13:03:28 +0200

> Daniel Borkmann (2):
>   net: sctp: spare unnecessary comparison in sctp_trans_elect_best
>   net: sctp: fix suboptimal edge-case on non-active active/retrans path selection

Both applied, thanks.

 
