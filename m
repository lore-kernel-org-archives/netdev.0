From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] openvswitch: fix trivial comment typo
Date: Mon, 14 Dec 2015 14:00:22 -0500 (EST)
Message-ID: <20151214.140022.2303208414121788568.davem@davemloft.net>
References: <aa5f132cc2095dbce252b320ca50c275c85ef4fa.1450092360.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pshelar@nicira.com, trivial@kernel.org,
	joestringer@nicira.com, dev@openvswitch.org
To: pabeni@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58639 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932175AbbLNTA0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Dec 2015 14:00:26 -0500
In-Reply-To: <aa5f132cc2095dbce252b320ca50c275c85ef4fa.1450092360.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paolo Abeni <pabeni@redhat.com>
Date: Mon, 14 Dec 2015 14:29:58 +0100

> The commit 33db4125ec74 ("openvswitch: Rename LABEL->LABELS") left
> over an old OVS_CT_ATTR_LABEL instance, fix it.
> 
> Fixes: 33db4125ec74 ("openvswitch: Rename LABEL->LABELS")
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>

Applied, thanks.
