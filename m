From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: Stable request 9374e7d2 "rtlwifi: rtl8192cu: Add new device ID"
Date: Tue, 28 Apr 2015 10:23:28 -0500
Message-ID: <553FA5F0.1070402@lwfinger.net>
References: <1430230954.6036.4@alarsen-lx> <201504281633.17160.marex@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Marek Vasut <marex@denx.de>, Anders Larsen <al@alarsen.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Stable <stable@vger.kernel.org>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <201504281633.17160.marex@denx.de>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please note that there are two commits just added to the mainline repo that 
should be propagated to all stable kernels. Both are addition of new USB IDs for 
an old driver, thus they will cause to side effects. Unfortunately, the Cc to 
stable was missed in the first of these, thus the need for this message. The 
second was Cc for stable, but I include it here for completeness.

The two commits in question are

commit 9374e7d2fdcad3c36dafc8d3effd554bc702c4b6
Author: Marek Vasut <marex@denx.de>
Date:   Thu Mar 26 02:16:06 2015 +0100

     rtlwifi: rtl8192cu: Add new device ID

     Add new ID for ASUS N10 WiFi dongle.

commit 2f92b314f4daff2117847ac5343c54d3d041bf78
Author: Larry Finger <Larry.Finger@lwfinger.net>
Date:   Mon Mar 23 18:14:10 2015 -0500

     rtlwifi: rtl8192cu: Add new USB ID

     USB ID 2001:330d is used for a D-Link DWA-131.


Thanks,

Larry
