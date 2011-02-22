From: hayeswang <hayeswang@realtek.com>
Subject: RE: [PATCH 3/5] r8169: fix the wrong parameter of point address
Date: Tue, 22 Feb 2011 16:46:02 +0800
Message-ID: <F0C0A9D890424ECAAB19523FCC4A2FCC@realtek.com.tw>
References: <1298356917-486-1-git-send-email-hayeswang@realtek.com> <1298356917-486-3-git-send-email-hayeswang@realtek.com> <20110222080017.GA12453@electric-eye.fr.zoreil.com> <20110222082153.GA12463@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: 'Francois Romieu' <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110222082153.GA12463@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 

> -----Original Message-----
> From: Francois Romieu [mailto:romieu@fr.zoreil.com] 
> Sent: Tuesday, February 22, 2011 4:22 PM
> To: Hayeswang
> Cc: netdev@vger.kernel.org; linux-kernel@vger.kernel.org
> Subject: Re: [PATCH 3/5] r8169: fix the wrong parameter of 
> point address
> 
> Francois Romieu <romieu@fr.zoreil.com> :
> > Hayes Wang <hayeswang@realtek.com> :
> > > Correct the parameter of rtl8168_oob_notify. It results 
> in the wrong 
> > > point address and influences RTL8168DP.
> > 
> > Please send this one separately as a patch against current 
> kernel tree 
> > as it is clearly a bugfix. The remaining patches are probably more 
> > -next material.
> 
> Correct me if I am wrong:
> - #3 and #1 are bugfixes
> - can you specify if #4 and #5 are either bugfixes, 
> optimizations or cleanups ?
> - #2 adds support for a new chipset

#1, #3, #4 are bugfixes.
#2 adds support for a new chipset
#5 is cleanup.

I would separate them and send the patches again.

 
Best Regards,
Hayes
