From: David Miller <davem@davemloft.net>
Subject: Re: [V3 PATCH 5/9] csiostor: Chelsio FCoE offload driver
 submission (sources part 5).
Date: Tue, 11 Sep 2012 13:35:10 -0400 (EDT)
Message-ID: <20120911.133510.1351483747174862495.davem@davemloft.net>
References: <1347374347-3852-1-git-send-email-naresh@chelsio.com>
	<1347374347-3852-6-git-send-email-naresh@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: JBottomley@parallels.com, linux-scsi@vger.kernel.org,
	dm@chelsio.com, leedom@chelsio.com, netdev@vger.kernel.org,
	chethan@chelsio.com
To: naresh@chelsio.com
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <1347374347-3852-6-git-send-email-naresh@chelsio.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Naresh Kumar Inna <naresh@chelsio.com>
Date: Tue, 11 Sep 2012 20:09:03 +0530

> +#include <linux/moduleparam.h>

This header include is not necessary.
