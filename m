From: Andrew Morton <akpm@osdl.org>
Subject: Re: [patch 2.6.13-rc6] net/802/tr: use interrupt-safe locking
Date: Sun, 21 Aug 2005 01:38:55 -0700
Message-ID: <20050821013855.6263eac9.akpm@osdl.org>
References: <20050817204959.GA20186@tuxdriver.com>
	<200508172148.j7HLmPAt005857@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-tr@linuxtr.net, mikep@linuxtr.net,
	jgarzik@pobox.com, davem@davemloft.net,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750873AbVHUInr@vger.kernel.org>
To: Jay Vosburgh <fubar@us.ibm.com>
In-Reply-To: <200508172148.j7HLmPAt005857@death.nxdomain.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jay Vosburgh <fubar@us.ibm.com> wrote:
>
>  >FWIW, this patch is currently being carried in the Fedora and RHEL
>  >kernels.  It certainly looks like it is necessary to me.  Can we get
>  >some movement on this?
> 
>  	It's in the SuSE kernel as well.

For how long has this fix been in the vendor kernels?

Could someone please tell us why there are unmerged bugfixes in vendor
kernels?

Are there any more?
