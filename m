From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/5] drivers: net: usb: rtl8150: bug fixing and cleanup
Date: Mon, 20 May 2013 00:00:46 -0700 (PDT)
Message-ID: <20130520.000046.631828458050532836.davem@davemloft.net>
References: <alpine.DEB.2.02.1305191136360.4537@fry.nucleusys.com>
	<20130519190116.GA4019@electric-eye.fr.zoreil.com>
	<alpine.DEB.2.02.1305200941260.4719@fry.nucleusys.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: petkan@nucleusys.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.02.1305200941260.4719@fry.nucleusys.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Petko Manolov <petkan@nucleusys.com>
Date: Mon, 20 May 2013 09:58:39 +0300 (EEST)

> So first apply patch #1 and then patch #2.

Then nobody can properly GIT bisect through your patch series.

The tree must work and build properly at each and every step
of your patch series.
