From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 7/7] tulip: remove redundant D0 power state set
Date: Fri, 31 May 2013 01:39:43 -0700 (PDT)
Message-ID: <20130531.013943.1014215784313697848.davem@davemloft.net>
References: <1369909626-37832-1-git-send-email-wangyijing@huawei.com>
	<CAP6odjieAiXxotVpE6fyFp7KS-1GXHdKpWXymtT96fRek5ewoQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wangyijing@huawei.com, grundler@parisc-linux.org,
	guohanjun@huawei.com, liuj97@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: grantgrundler@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34664 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751184Ab3EaIjo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 May 2013 04:39:44 -0400
In-Reply-To: <CAP6odjieAiXxotVpE6fyFp7KS-1GXHdKpWXymtT96fRek5ewoQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Grant Grundler <grantgrundler@gmail.com>
Date: Thu, 30 May 2013 08:31:38 -0700

> On Thu, May 30, 2013 at 3:27 AM, Yijing Wang <wangyijing@huawei.com> wrote:
>> Pci_enable_device() will set device power state to D0,
>> so it's no need to do it again in tulip_init_one().
>>
>> Signed-off-by: Yijing Wang <wangyijing@huawei.com>
> 
> Ack-by: Grant Grundler <grundler@parisc-linux.org>

(it's Acked-by)  Applied, thanks.
