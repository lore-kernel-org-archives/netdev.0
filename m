From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: Re: [PATCH net-next 09/11] qede: Better utilize the qede_[rt]x_queue
Date: Sun, 27 Nov 2016 21:17:54 +0000
Message-ID: <BL2PR07MB2306A780C3425AABA747BECB8D8B0@BL2PR07MB2306.namprd07.prod.outlook.com>
References: <1480258273-24973-10-git-send-email-Yuval.Mintz@cavium.com>
        <201611272330.xRUonBtv%fengguang.wu@intel.com>
        <BL2PR07MB23064E75618105466EAA79A68D8B0@BL2PR07MB2306.namprd07.prod.outlook.com>,<20161127.151631.150312523846891505.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: "lkp@intel.com" <lkp@intel.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0074.outbound.protection.outlook.com ([104.47.33.74]:5184
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753596AbcK0VR5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 27 Nov 2016 16:17:57 -0500
In-Reply-To: <20161127.151631.150312523846891505.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > I'd say this is a false positive, given that MTU can't be so large.

> False positive or not you must fix the warning and resubmit this
> series with that fixed.

Sure. I'll re-spin later this week [hopefully it'll get some additional
review comments by then]. =
