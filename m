From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv4: fix redirect handling for TCP packets
Date: Mon, 27 May 2013 23:23:50 -0700 (PDT)
Message-ID: <20130527.232350.1126293930261151421.davem@davemloft.net>
References: <20130527080120.424C662C67@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
To: mkubecek@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49608 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932989Ab3E1GXv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 May 2013 02:23:51 -0400
In-Reply-To: <20130527080120.424C662C67@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Kubecek <mkubecek@suse.cz>
Date: Mon, 27 May 2013 09:47:56 +0200

> Issue was introduced by commit 4895c771c (v3.6-rc1).

This string in parenthesis is not from the commit that introduced the
problem, it's from some random release tag after the commit.

You should always reference changes like this:

	$SHA1ID ("Header line of the $SHA1ID commits message.")

Please fix this up and resubmit, thanks.
