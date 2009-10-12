From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] ixgbe: Use the instance of
 net_device_stats from net_device.
Date: Mon, 12 Oct 2009 16:30:22 -0700 (PDT)
Message-ID: <20091012.163022.31858450.davem@davemloft.net>
References: <20091007124339.GA30083@serverengines.com>
	<EA929A9653AAE14F841771FB1DE5A1365F98A89A0B@rrsmsx501.amr.corp.intel.com>
	<20091012121055.GA10799@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: emil.s.tantilov@intel.com, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com
To: ajitk@serverengines.com, ajitkhaparde@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54914
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754857AbZJLXa0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2009 19:30:26 -0400
In-Reply-To: <20091012121055.GA10799@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ajit Khaparde <ajitkhaparde@gmail.com>
Date: Mon, 12 Oct 2009 17:40:57 +0530

> There was an error in the way I was trying to offset for the netdev stats.
> I have a fix for it now.  I would like to know if you would prefer an
> incremental patch or a patch with the previous changes too. 
> I will mail the patches accordingly.  Sorry for the delay in sending this out.

Since your patch has been in my tree for more than a week the only
possible thing you can send is a incremental fix.
