From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] Misc SCTP updates
Date: Wed, 02 Jul 2014 18:44:34 -0700 (PDT)
Message-ID: <20140702.184434.230277799268351675.davem@davemloft.net>
References: <1404129129-23270-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42710 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750809AbaGCBog (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2014 21:44:36 -0400
In-Reply-To: <1404129129-23270-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Mon, 30 Jun 2014 13:52:07 +0200

> Daniel Borkmann (2):
>   net: sctp: improve timer slack calculation for transport HBs
>   net: sctp: only warn in proc_sctp_do_alpha_beta if write

Series applied, thanks Daniel.
