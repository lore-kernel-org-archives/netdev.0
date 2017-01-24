From: David Miller <davem@davemloft.net>
Subject: Re: [RESENT PATCH net,stable] qmi_wwan/cdc_ether: add device ID
 for HP lt2523 (Novatel E371) WWAN card
Date: Tue, 24 Jan 2017 15:25:36 -0500 (EST)
Message-ID: <20170124.152536.539823117408876472.davem@davemloft.net>
References: <20170124094538.20351-1-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, oliver@neukum.org,
        linux-usb@vger.kernel.org, dcbw@redhat.com
To: bjorn@mork.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59208 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750752AbdAXUZh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 15:25:37 -0500
In-Reply-To: <20170124094538.20351-1-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bjørn Mork <bjorn@mork.no>
Date: Tue, 24 Jan 2017 10:45:38 +0100

> Another rebranded Novatel E371.  qmi_wwan should drive this device, while
> cdc_ether should ignore it.  Even though the USB descriptors are plain
> CDC-ETHER that USB interface is a QMI interface.  Ref commit 7fdb7846c9ca
> ("qmi_wwan/cdc_ether: add device IDs for Dell 5804 (Novatel E371) WWAN
> card")
> 
> Cc: Dan Williams <dcbw@redhat.com>
> Signed-off-by: Bjørn Mork <bjorn@mork.no>

Applied.
