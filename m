From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: Re: [PATCH v2 5/5] stmmac: pci: remove FSF address
Date: Tue, 04 Nov 2014 11:06:24 +0200
Message-ID: <1415091984.472.3.camel@linux.intel.com>
References: <1415019737-32736-1-git-send-email-andriy.shevchenko@linux.intel.com>
	 <1415019737-32736-6-git-send-email-andriy.shevchenko@linux.intel.com>
	 <20141103.155708.1102581898193715225.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org,
	hock.leong.kweh@intel.com, vbridgers2013@gmail.com,
	rayagond@vayavyalabs.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:58293 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752417AbaKDJGZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Nov 2014 04:06:25 -0500
In-Reply-To: <20141103.155708.1102581898193715225.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-11-03 at 15:57 -0500, David Miller wrote:
> From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
> Date: Mon,  3 Nov 2014 15:02:17 +0200
> 
> > The FSF address is subject to change, thus remove it from the file.
> > 
> > Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
> 
> I cound 90t instances of this under drivers/net, therefore if this change is
> appropriate 

Can't find fast the discussion, but there is the commit
4783f894d0f3bfb107cf3b1d9aed1f1a0672ee1d "checkpatch.pl: check for the
FSF mailing address".


> I'd rather someone script this and kill it across entire
> subdirectories.

I'm okay if you don't apply this patch now.


-- 
Andy Shevchenko <andriy.shevchenko@intel.com>
Intel Finland Oy
