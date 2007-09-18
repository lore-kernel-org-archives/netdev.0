From: David Miller <davem@davemloft.net>
Subject: Re: net-2.6.24 plans
Date: Mon, 17 Sep 2007 17:04:50 -0700 (PDT)
Message-ID: <20070917.170450.10298786.davem@davemloft.net>
References: <20070916.202258.03371690.davem@davemloft.net>
	<20070917.141826.70218261.davem@davemloft.net>
	<BAE9DCEF64577A439B3A37F36F9B691C030EF13C@orsmsx418.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	linville@tuxdriver.com, jgarzik@pobox.com
To: shannon.nelson@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39910
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756556AbXIRAE7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Sep 2007 20:04:59 -0400
In-Reply-To: <BAE9DCEF64577A439B3A37F36F9B691C030EF13C@orsmsx418.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Nelson, Shannon" <shannon.nelson@intel.com>
Date: Mon, 17 Sep 2007 16:57:03 -0700

> >From: netdev-owner@vger.kernel.org 
> >[mailto:netdev-owner@vger.kernel.org] On Behalf Of David Miller
> >Sent: Monday, September 17, 2007 2:18 PM
> >To: netdev@vger.kernel.org
> >Cc: akpm@linux-foundation.org; linville@tuxdriver.com; 
> >jgarzik@pobox.com
> >Subject: Re: net-2.6.24 plans
> [...]
> >
> >Andrew, I removed the troublesome IOAT patch.  The only conflicts
> >and fixes you should need at this point are:
> >
> [...]
> 
> Which IOAT patch are you referring to?

The 'uninitialized variable' one, you should have a copy.
If not, Andrew definitely does.
