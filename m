From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: bridge: br_set_ageing_time takes a clock_t
Date: Mon, 25 Jul 2016 10:31:32 -0700 (PDT)
Message-ID: <20160725.103132.907319471508276481.davem@davemloft.net>
References: <20160721164219.26723-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com, stephen@networkplumber.org
To: vivien.didelot@savoirfairelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42458 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752882AbcGYRbd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jul 2016 13:31:33 -0400
In-Reply-To: <20160721164219.26723-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Thu, 21 Jul 2016 12:42:19 -0400

> Change the ageing_time type in br_set_ageing_time() from u32 to what it
> is expected to be, i.e. a clock_t.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Applied.
