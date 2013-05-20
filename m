From: Petko Manolov <petkan@nucleusys.com>
Subject: Re: [PATCH 1/5] drivers: net: usb: rtl8150: bug fixing and cleanup
Date: Mon, 20 May 2013 10:09:00 +0300 (EEST)
Message-ID: <alpine.DEB.2.02.1305201008190.4719@fry.nucleusys.com>
References: <alpine.DEB.2.02.1305191136360.4537@fry.nucleusys.com> <20130519190116.GA4019@electric-eye.fr.zoreil.com> <alpine.DEB.2.02.1305200941260.4719@fry.nucleusys.com> <20130520.000046.631828458050532836.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130520.000046.631828458050532836.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 20 May 2013, David Miller wrote:

> From: Petko Manolov <petkan@nucleusys.com>
> Date: Mon, 20 May 2013 09:58:39 +0300 (EEST)
> 
> > So first apply patch #1 and then patch #2.
> 
> Then nobody can properly GIT bisect through your patch series.
> 
> The tree must work and build properly at each and every step
> of your patch series.

Got it.  What about the .c/.h split?
