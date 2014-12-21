From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/2] 8139too in linux-3.18.0: Fix the lack of
 pci_disable_device
Date: Sun, 21 Dec 2014 13:15:05 -0500 (EST)
Message-ID: <20141221.131505.235781660190455895.davem@davemloft.net>
References: <000001d01c5f$650f3270$2f2d9750$@163.com>
	<54958534.7070202@cogentembedded.com>
	<5496788B.2030105@163.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sergei.shtylyov@cogentembedded.com, netdev@vger.kernel.org,
	jgarzik@pobox.com, shangh@realtek.com.tw,
	bjj13@mails.tsinghua.edu.cn
To: baijiaju1990@163.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57958 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751277AbaLUSPK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Dec 2014 13:15:10 -0500
In-Reply-To: <5496788B.2030105@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jia-Ju Bai <baijiaju1990@163.com>
Date: Sun, 21 Dec 2014 15:36:43 +0800

> When pci_request_regions is failed in rtl8139_init_board,
> pci_disable_device is not called to disable the device which are
> enabled by pci_enable_device, because disable_dev_on_err is not
> assigned 1.
> This patch fix this problem.
> 
> Signed-off-by: Jia-Ju Bai <baijiaju1990@163.com>

Your patches are severely corrupted by your email client, and thus
are not usable.
