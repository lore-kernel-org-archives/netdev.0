From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] s390: af_iucv patches
Date: Wed, 15 Jun 2016 12:21:19 -0700 (PDT)
Message-ID: <20160615.122119.1427241587691206999.davem@davemloft.net>
References: <1465836376-24452-1-git-send-email-ubraun@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	utz.bacher@de.ibm.com
To: ubraun@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33369 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933099AbcFOTVV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 15:21:21 -0400
In-Reply-To: <1465836376-24452-1-git-send-email-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Date: Mon, 13 Jun 2016 18:46:13 +0200

> here are improvements for af_iucv relaxing the pressure to allocate
> big contiguous kernel buffers.

Series applied.
