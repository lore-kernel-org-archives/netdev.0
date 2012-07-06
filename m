From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH v2 net-next 2/2] r8169: support RTL8168G
Date: Fri, 6 Jul 2012 17:20:06 +0200
Message-ID: <20120706152006.GA6981@electric-eye.fr.zoreil.com>
References: <1340966060-2749-1-git-send-email-hayeswang@realtek.com> <1341221002-1522-1-git-send-email-hayeswang@realtek.com> <1341221002-1522-2-git-send-email-hayeswang@realtek.com> <20120704220458.GA1621@electric-eye.fr.zoreil.com> <43E32504589B47B9846C4E9DAF98BF60@realtek.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: hayeswang <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <43E32504589B47B9846C4E9DAF98BF60@realtek.com.tw>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

hayeswang <hayeswang@realtek.com> :
> Francois Romieu [romieu@fr.zoreil.com]
[...]
> > - fix r8168g_mdio_write (if (reg_addr == 0x1f) { if (reg_addr == 0) snafu)
> >   -> Please check this one.
> 
> That is fine.

Thanks, I'll merge your patch and feed both drivers to davem.

-- 
Ueimor
