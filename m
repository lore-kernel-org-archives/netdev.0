From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 3/5] r8169: fix the wrong parameter of point address
Date: Tue, 22 Feb 2011 09:00:17 +0100
Message-ID: <20110222080017.GA12453@electric-eye.fr.zoreil.com>
References: <1298356917-486-1-git-send-email-hayeswang@realtek.com> <1298356917-486-3-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1298356917-486-3-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hayes Wang <hayeswang@realtek.com> :
> Correct the parameter of rtl8168_oob_notify. It results in the
> wrong point address and influences RTL8168DP.

Please send this one separately as a patch against current kernel
tree as it is clearly a bugfix. The remaining patches are probably
more -next material.

-- 
Ueimor
