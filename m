From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 0/2] sctp: fix a problem with net_namespace
Date: Thu, 13 Feb 2014 17:13:39 -0500 (EST)
Message-ID: <20140213.171339.128629799445150745.davem@davemloft.net>
References: <1392169484-8256-1-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, vyasevich@gmail.com, dborkman@redhat.com,
	sergei.shtylyov@cogentembedded.com, netdev@vger.kernel.org
To: wangweidong1@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50613 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752153AbaBMWNl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 17:13:41 -0500
In-Reply-To: <1392169484-8256-1-git-send-email-wangweidong1@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Weidong <wangweidong1@huawei.com>
Date: Wed, 12 Feb 2014 09:44:42 +0800

> fix a problem with net_namespace, and optimize
> the sctp_sysctl_net_register.
> 
> v2 -> v3:
>   -patch2: add empty line after declaration as potined out by Sergei.
> 
> v1 -> v2:
>   -patch1: add Neil's ACK.
> 
> Wang Weidong (2):
>   sctp: fix a missed .data initialization
>   sctp: optimize the sctp_sysctl_net_register

Series applied, thanks.
