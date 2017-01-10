From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] net: ipv6: put autoconf routes into
 per-interface tables
Date: Mon, 9 Jan 2017 19:08:57 -0700
Message-ID: <e282793e-4057-7fe6-8322-e1899d873ae2@cumulusnetworks.com>
References: <20170106153026.24785-1-lorenzo@google.com>
 <37df3b18-d17b-5875-7b44-db40be7b459c@cumulusnetworks.com>
 <CAKD1Yr2U2Oh5yvHE7Znfc9mHzM4K6B_kU82Qctpcsmnt3y5GdQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        =?UTF-8?Q?Maciej_=c5=bbenczykowski?= <zenczykowski@gmail.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Erik Kline <ek@google.com>,
        YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>,
        David Miller <davem@davemloft.net>,
        Daniel Rosenberg <drosen@google.com>
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:33615 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751784AbdAJCI7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 21:08:59 -0500
Received: by mail-pf0-f182.google.com with SMTP id y143so16604210pfb.0
        for <netdev@vger.kernel.org>; Mon, 09 Jan 2017 18:08:59 -0800 (PST)
In-Reply-To: <CAKD1Yr2U2Oh5yvHE7Znfc9mHzM4K6B_kU82Qctpcsmnt3y5GdQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/9/17 7:01 PM, Lorenzo Colitti wrote:
> As others have mentioned, IPv6 on VRFs in client mode is also not
> necessarily well-supported at the moment, and I don't know how long it
> would take for it to be (assuming it can be made to work properly in
> client mode without breaking the primary use cases for VRFs).

That's news to me. What about IPv6 and VRF is not working or well-supported?
