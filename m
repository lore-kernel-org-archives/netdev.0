From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next 5/7] r8169: add a new chip for RTL8111G
Date: Wed, 3 Apr 2013 01:20:08 +0200
Message-ID: <20130402232008.GB16612@electric-eye.fr.zoreil.com>
References: <1364824539-4156-1-git-send-email-hayeswang@realtek.com>
 <1364824539-4156-5-git-send-email-hayeswang@realtek.com>
 <20130401222235.GB19335@electric-eye.fr.zoreil.com>
 <2808A1ABA9A5470C8CB9534309588984@realtek.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: hayeswang <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <2808A1ABA9A5470C8CB9534309588984@realtek.com.tw>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

hayeswang <hayeswang@realtek.com> :
> Francois Romieu [mailto:romieu@fr.zoreil.com] 
[...]
> > There is close to zero added value for this stuff in the kernel.
> > You may as well move it completely into the firmware.
> 
> Do you mean all of the phy settings ? I have checked these settings with
> our hw engineers. These are not firmware. 

Undocumented configuration data which is subject to change over time ?

No one outside of Realtek can make any sense of this opaque pile of data.
There is no point in me or anybody else rubber stamping it for inclusion.

-- 
Ueimor
