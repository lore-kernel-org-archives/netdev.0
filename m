From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next 00/11] net: L3 master device
Date: Tue, 29 Sep 2015 21:04:35 -0700 (PDT)
Message-ID: <20150929.210435.1043794301164447536.davem@davemloft.net>
References: <1443582438-23823-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dsahern@gmail.com
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33197 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750768AbbI3EEi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2015 00:04:38 -0400
In-Reply-To: <1443582438-23823-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Tue, 29 Sep 2015 20:07:09 -0700

> v3
> - added license header to l3mdev.c
> 
> - export symbols in l3mdev.c for use with GPL modules
> 
> - removed netdevice header from l3mdev.h (not needed) and fixed
>   typo in comment

Series applied, thanks David.
