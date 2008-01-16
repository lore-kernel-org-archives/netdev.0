From: David Miller <davem@davemloft.net>
Subject: Re: [REGRESSION] 2.6.24-rc7: e1000: Detected Tx Unit Hang
Date: Wed, 16 Jan 2008 02:29:53 -0800 (PST)
Message-ID: <20080116.022953.184520911.davem@davemloft.net>
References: <36D9DB17C6DE9E40B059440DB8D95F52042FA541@orsmsx418.amr.corp.intel.com>
	<20080115.210214.170759690.davem@davemloft.net>
	<200801160956.09053.elendil@planet.nl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jesse.brandeburg@intel.com, slavon@bigtelecom.ru,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: elendil@planet.nl
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753940AbYAPKaX@vger.kernel.org>
In-Reply-To: <200801160956.09053.elendil@planet.nl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Frans Pop <elendil@planet.nl>
Date: Wed, 16 Jan 2008 09:56:08 +0100

> On Wednesday 16 January 2008, David Miller wrote:
> > Ok, here is the patch I'll propose to fix this.  The goal is to make
> > it as simple as possible without regressing the thing we were trying
> > to fix.
> 
> Looks good to me. Tested with -rc8.

Thanks for testing.
