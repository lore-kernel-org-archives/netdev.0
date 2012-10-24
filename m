From: hayeswang <hayeswang@realtek.com>
Subject: RE: [PATCH net-next 1/2] r8169: enable ALDPS for power saving
Date: Wed, 24 Oct 2012 13:55:28 +0800
Message-ID: <B3B61E0990514F28A8203537EB9D047A@realtek.com.tw>
References: <1350893153-18320-1-git-send-email-hayeswang@realtek.com> <20121022192748.GA16370@electric-eye.fr.zoreil.com> <D81B36B929404E28AE7007B7E21B9D46@realtek.com.tw> <20121023193146.GA10463@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: 'Francois Romieu' <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20121023193146.GA10463@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 Francois Romieu [mailto:romieu@fr.zoreil.com] 
[...]
> It would be nice to state these things in the commit message, namely:
> - ALDPS should never be enabled for the RTL8105e
> - none of the firmware-free chipsets support ALDPS
> - neither do the RTL8168d/8111d

Excuse me. I don't understand why the RTL8105e shouldn't enable ALDPS.
 
Best Regards,
Hayes
