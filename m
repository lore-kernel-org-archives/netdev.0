From: David Miller <davem@davemloft.net>
Subject: Re: [net-next] dummy: declare dummy devices as enumerated devices
Date: Mon, 18 Sep 2017 11:29:42 -0700 (PDT)
Message-ID: <20170918.112942.292129633205088909.davem@davemloft.net>
References: <1505179965-12117-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ezegomez@amazon.com
To: zhangshengju@cmss.chinamobile.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47952 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753819AbdIRS3n (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 14:29:43 -0400
In-Reply-To: <1505179965-12117-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Date: Tue, 12 Sep 2017 09:32:45 +0800

> Dummy device name is enumerated by the kernel, let user space be aware
> of the naming scheme used by dummy devices:
> (visible in /sys/class/net/<iface>/name_assign_type).
> 
> Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>

Applied.
