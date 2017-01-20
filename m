From: Hayes Wang <hayeswang@realtek.com>
Subject: RE: [PATCH net] r8152: fix the rx doesn't work
Date: Fri, 20 Jan 2017 06:30:40 +0000
Message-ID: <0835B3720019904CB8F7AA43166CEEB2010752DF@RTITMBSV03.realtek.com.tw>
References: <1394712342-15778-233-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: nic_swsd <nic_swsd@realtek.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([211.75.126.72]:45919 "EHLO
        rtits2.realtek.com.tw" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751267AbdATGan (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 01:30:43 -0500
In-Reply-To: <1394712342-15778-233-Taiwan-albertk@realtek.com>
Content-Language: zh-TW
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Subject: [PATCH net] r8152: fix the rx doesn't work
> 
> The rtl8152_post_reset() doesn't submit the rx urb, so the rx wouldn't work.
> 
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>

Excuse me. Please ignore this patch. I would submit another one.
