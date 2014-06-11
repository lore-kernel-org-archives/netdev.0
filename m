From: David Miller <davem@davemloft.net>
Subject: Re: [patch] qlcnic: remove duplicate QLC_83XX_GET_LSO_CAPABILITY
 define
Date: Wed, 11 Jun 2014 15:01:53 -0700 (PDT)
Message-ID: <20140611.150153.1890331283649482551.davem@davemloft.net>
References: <20140609145539.GB9600@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shahed.shaikh@qlogic.com, Dept-HSGLinuxNICDev@qlogic.com,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47447 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751797AbaFKWBy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2014 18:01:54 -0400
In-Reply-To: <20140609145539.GB9600@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Mon, 9 Jun 2014 17:55:39 +0300

> The QLC_83XX_GET_LSO_CAPABILITY define is cut and pasted twice so we can
> delete the second instance.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
