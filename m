From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH 07/11] wireless: ipw2x00: convert to use DRIVER_ATTR_RW
Date: Fri, 09 Jun 2017 12:25:44 +0300
Message-ID: <87h8zp4inb.fsf@codeaurora.org>
References: <20170609090314.13991-1-gregkh@linuxfoundation.org>
        <20170609090314.13991-7-gregkh@linuxfoundation.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org,
        Stanislav Yakovlev <stas.yakovlev@gmail.com>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170609090314.13991-7-gregkh@linuxfoundation.org> (Greg
        Kroah-Hartman's message of "Fri, 9 Jun 2017 11:03:10 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Greg Kroah-Hartman <gregkh@linuxfoundation.org> writes:

> We are trying to get rid of DRIVER_ATTR(), and the ipw2x00 driver's
> attributes can be trivially changed to use DRIVER_ATTR_RW().
>
> Cc: Stanislav Yakovlev <stas.yakovlev@gmail.com>
> Cc: Kalle Valo <kvalo@codeaurora.org>
> Cc: <linux-wireless@vger.kernel.org>
> Cc: <netdev@vger.kernel.org>
> Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

Looks good to me. I assume that I should take this, but let me know if
you are planning to push this via your trees instead. Either way is fine
for me, I'm not expecting any conflicts here.

-- 
Kalle Valo
