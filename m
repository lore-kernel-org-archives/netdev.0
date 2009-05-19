From: David Miller <davem@davemloft.net>
Subject: Re: [IGB 2.6.29.3 bug] Re: WARNING at dev_disable_lro when
 enabling ip_forward
Date: Tue, 19 May 2009 15:14:51 -0700 (PDT)
Message-ID: <20090519.151451.136328237.davem@davemloft.net>
References: <20090518155714.0f1a3b20@nehalam>
	<20090519234629.2b5f7550@vingilot.sergknet>
	<9929d2390905191506t1fc203d3q98a7f89cbcda38ca@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sergk@sergk.org.ua, shemminger@vyatta.com, netdev@vger.kernel.org
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53313
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753441AbZESWOx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2009 18:14:53 -0400
In-Reply-To: <9929d2390905191506t1fc203d3q98a7f89cbcda38ca@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 19 May 2009 15:06:57 -0700

> Thanks Sergey and Stephen, I will get this queued up for the current
> and stable trees.

current doesn't need it, since igb uses GRO now.
