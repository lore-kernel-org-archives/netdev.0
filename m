From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4 0/2] RDS: TCP: tunable socket buffer
 parameters
Date: Fri, 18 Mar 2016 22:26:10 -0400 (EDT)
Message-ID: <20160318.222610.1796310147998392893.davem@davemloft.net>
References: <cover.1458152608.git.sowmini.varadhan@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, santosh.shilimkar@oracle.com,
	hannes@stressinduktion.org, eric.dumazet@gmail.com
To: sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58625 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751086AbcCSC0N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Mar 2016 22:26:13 -0400
In-Reply-To: <cover.1458152608.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Wed, 16 Mar 2016 11:38:11 -0700

> Patch 1 uses sysctl to create tunable socket buffer size parameters.
> 
> Patch 2 removes an unuused constant.
> 
> v2: use sysctl
> v3: review comments from Santosh Shilimkar, Eric Dumazet
> v4: review comments from Hannes Sowa

Series applied, thanks.
