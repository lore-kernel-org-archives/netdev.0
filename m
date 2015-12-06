From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] bnx2x: fewer error messages,
 simplification
Date: Sat, 05 Dec 2015 19:00:41 -0500 (EST)
Message-ID: <20151205.190041.1649257614460638080.davem@davemloft.net>
References: <1449246156-13796-1-git-send-email-mschmidt@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Yuval.Mintz@qlogic.com,
	Ariel.Elior@qlogic.com
To: mschmidt@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39896 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752064AbbLFAAn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Dec 2015 19:00:43 -0500
In-Reply-To: <1449246156-13796-1-git-send-email-mschmidt@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Schmidt <mschmidt@redhat.com>
Date: Fri,  4 Dec 2015 17:22:33 +0100

> This removes one redundant error message in bnx2x and changes
> another one to WARN_ONCE. The third patch is a small simplification
> in ethtool stats.

Series applied, thanks Michal!
