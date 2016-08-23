From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: Re: [PATCH -next] net: phy: xgmiitorgmii: Fix non static symbol
 warning
Date: Tue, 23 Aug 2016 23:41:25 +0800
Message-ID: <874c4fd0-ac5d-9db0-3470-e092b9251cd7@gmail.com>
References: <1471964765-32708-1-git-send-email-weiyj.lk@gmail.com>
 <20160823151619.GK20029@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, michal.simek@xilinx.com,
        soren.brinkmann@xilinx.com, netdev@vger.kernel.org,
        Wei Yongjun <weiyongjun1@huawei.com>,
        linux-arm-kernel@lists.infradead.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:36275 "EHLO
        mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751640AbcHWPlh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 11:41:37 -0400
Received: by mail-pa0-f68.google.com with SMTP id ez1so10114397pab.3
        for <netdev@vger.kernel.org>; Tue, 23 Aug 2016 08:41:37 -0700 (PDT)
In-Reply-To: <20160823151619.GK20029@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

On 08/23/2016 11:16 PM, Andrew Lunn wrote:
> On Tue, Aug 23, 2016 at 03:06:05PM +0000, Wei Yongjun wrote:
>> From: Wei Yongjun <weiyongjun1@huawei.com>
> Hi Wei
>
> No need for the additional From:
>
> git am will use the one in the mail header as the author of the patch,
> and it is in the signed-off-by as well.

The mail address which I sent the patch is different with the
signed-of-by one, so git send-email will not remove the From line.

Regards,
Yongjun Wei 
