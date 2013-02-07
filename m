From: hayeswang <hayeswang@realtek.com>
Subject: RE: [PATCH 3/5] r8169: Modify the method for setting firmware
Date: Thu, 7 Feb 2013 10:08:00 +0800
Message-ID: <69405959BD324BAC943970C031FD3D4B@realtek.com.tw>
References: <1360161987-3268-1-git-send-email-hayeswang@realtek.com> <1360161987-3268-3-git-send-email-hayeswang@realtek.com> <20130207000252.GB2784@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: 'Francois Romieu' <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130207000252.GB2784@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu [mailto:romieu@fr.zoreil.com] 
[...]
> 
> Did you check that none of rtl_nic/rtl8168d-{1, 2}.fw uses 
> PHY_READ_EFUSE ?
> 

I have made sure that none of the current firmwares use PHY_READ_EFUSE.
 
Best Regards,
Hayes
