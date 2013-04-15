From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: add dev_uc_sync_multiple() and
 dev_mc_sync_multiple() api
Date: Mon, 15 Apr 2013 15:44:55 -0400 (EDT)
Message-ID: <20130415.154455.853917359652831496.davem@davemloft.net>
References: <1366052997-12435-1-git-send-email-vyasevic@redhat.com>
	<1366052997-12435-2-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35739 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754351Ab3DOTo6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Apr 2013 15:44:58 -0400
In-Reply-To: <1366052997-12435-2-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vyasevic@redhat.com>
Date: Mon, 15 Apr 2013 15:09:56 -0400

> The current implementation of dev_uc_sync/unsync() assumes that there is
> a strict 1-to-1 relationship between the source and destination of the case.

What do you mean by "destination of the case", maybe use different words
here.
