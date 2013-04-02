From: hayeswang <hayeswang@realtek.com>
Subject: RE: [PATCH net-next 5/7] r8169: add a new chip for RTL8111G
Date: Tue, 2 Apr 2013 10:39:31 +0800
Message-ID: <2808A1ABA9A5470C8CB9534309588984@realtek.com.tw>
References: <1364824539-4156-1-git-send-email-hayeswang@realtek.com> <1364824539-4156-5-git-send-email-hayeswang@realtek.com> <20130401222235.GB19335@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: 'Francois Romieu' <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130401222235.GB19335@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu [mailto:romieu@fr.zoreil.com] 
> Sent: Tuesday, April 02, 2013 6:23 AM
> To: Hayeswang
> Cc: netdev@vger.kernel.org; linux-kernel@vger.kernel.org
> Subject: Re: [PATCH net-next 5/7] r8169: add a new chip for RTL8111G
> 
[..]
> There is close to zero added value for this stuff in the kernel.
> You may as well move it completely into the firmware.

Do you mean all of the phy settings? I have checked these settings with our hw
engineers. These are not firmware. 

Best Regards,
Hayes
