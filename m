From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: ipv6: remove 'next' member from inet6_dev
Date: Mon, 20 May 2013 13:50:13 -0700 (PDT)
Message-ID: <20130520.135013.2120743819962850485.davem@davemloft.net>
References: <1369061618-22650-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37801 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756561Ab3ETUuN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 May 2013 16:50:13 -0400
In-Reply-To: <1369061618-22650-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Mon, 20 May 2013 16:53:38 +0200

> The next pointer within the inet6_dev structure seems not to be used
> anywhere. So just remove it. Tested with allmodconfig on x86_64.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Applied.
