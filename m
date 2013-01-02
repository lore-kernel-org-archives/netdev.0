From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/3] netpoll: prepare for ipv6
Date: Tue, 01 Jan 2013 23:07:12 -0800 (PST)
Message-ID: <20130101.230712.118939414426489213.davem@davemloft.net>
References: <1357027288-28675-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38706 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751404Ab3ABHHQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jan 2013 02:07:16 -0500
In-Reply-To: <1357027288-28675-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Tue,  1 Jan 2013 16:01:26 +0800

> +	int ipv6;

Use 'bool' please.
