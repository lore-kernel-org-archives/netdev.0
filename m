From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cipso: simplify cipso_v4_translate() when
 !CONFIG_NETLABEL
Date: Wed, 20 Nov 2013 14:34:07 -0500 (EST)
Message-ID: <20131120.143407.4095832971724166.davem@davemloft.net>
References: <20131120192548.5616.74526.stgit@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: pmoore@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36399 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754628Ab3KTTeL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Nov 2013 14:34:11 -0500
In-Reply-To: <20131120192548.5616.74526.stgit@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Moore <pmoore@redhat.com>
Date: Wed, 20 Nov 2013 14:25:48 -0500

> Previous commits corrected some problems with cipso_v4_translate()
> when CONFIG_NETLABEL=n but some additional work is needed to tidy
> things up a bit.
> 
> Signed-off-by: Paul Moore <pmoore@redhat.com>

That's really vague, please describe exactly what is wrong with the
existing conditional and how you have fixed it.
