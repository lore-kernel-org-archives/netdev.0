From: Hin-Tak Leung <htl10@users.sourceforge.net>
Subject: Re: [PATCH 31/35] wireless: realtek: rtl8187: constify
 usb_device_id
Date: Fri, 25 Aug 2017 21:05:27 +0000 (UTC)
Message-ID: <1571555159.3124994.1503695127129@mail.yahoo.com>
References: <1571555159.3124994.1503695127129.ref@mail.yahoo.com>
Reply-To: Hin-Tak Leung <htl10@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
        <linux-wireless@vger.kernel.org>
To: <kvalo@codeaurora.org>, <herton@canonical.com>,
        <Larry.Finger@lwfinger.net>,
        Arvind Yadav <arvind.yadav.cs@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--------------------------------------------
On Tue, 8/8/17, Arvind Yadav <arvind.yadav.cs@gmail.com> wrote:

 Subject: [PATCH 31/35] wireless: realtek: rtl8187: constify usb_device_id
 To: kvalo@codeaurora.org, herton@canonical.com, htl10@users.sourceforge.net, Larry.Finger@lwfinger.net
 Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org, linux-wireless@vger.kernel.org
 Date: Tuesday, 8 August, 2017, 17:04
 
> usb_device_id are not supposed to change at
> runtime. All functions
> working with usb_device_id provided by
> <linux/usb.h> work with
> const usb_device_id. So mark the
> non-const structs as const.
 
> Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
 
Acked-by: htl10@users.sourceforge.net
