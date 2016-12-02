From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] NET: usb: qmi_wwan: add support for Telit LE922A
 PID 0x1040
Date: Fri, 02 Dec 2016 13:42:33 -0500 (EST)
Message-ID: <20161202.134233.1733247770650768156.davem@davemloft.net>
References: <1480607525-23044-1-git-send-email-dnlplm@gmail.com>
        <1480607525-23044-2-git-send-email-dnlplm@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bjorn@mork.no, netdev@vger.kernel.org
To: dnlplm@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38482 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751515AbcLBSne (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 13:43:34 -0500
In-Reply-To: <1480607525-23044-2-git-send-email-dnlplm@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniele Palmas <dnlplm@gmail.com>
Date: Thu,  1 Dec 2016 16:52:05 +0100

> This patch adds support for PID 0x1040 of Telit LE922A.
> 
> The qmi adapter requires to have DTR set for proper working,
> so QMI_WWAN_QUIRK_DTR has been enabled.
> 
> Signed-off-by: Daniele Palmas <dnlplm@gmail.com>

Applied.
