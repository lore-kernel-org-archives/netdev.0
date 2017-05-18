From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net,stable] qmi_wwan: add another Lenovo EM74xx device
 ID
Date: Thu, 18 May 2017 10:25:20 -0400 (EDT)
Message-ID: <20170518.102520.443372921704705110.davem@davemloft.net>
References: <20170517143141.28483-1-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: bjorn@mork.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43364 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755864AbdEROZW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 May 2017 10:25:22 -0400
In-Reply-To: <20170517143141.28483-1-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bjørn Mork <bjorn@mork.no>
Date: Wed, 17 May 2017 16:31:41 +0200

> In their infinite wisdom, and never ending quest for end user frustration,
> Lenovo has decided to use a new USB device ID for the wwan modules in
> their 2017 laptops.  The actual hardware is still the Sierra Wireless
> EM7455 or EM7430, depending on region.
> 
> Signed-off-by: Bjørn Mork <bjorn@mork.no>

Applied and queued up for -stable, thank you.
