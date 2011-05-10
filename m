From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/usb: mark LG VL600 LTE modem ethernet interface as
 WWAN
Date: Tue, 10 May 2011 13:14:16 -0700 (PDT)
Message-ID: <20110510.131416.28824429.davem@davemloft.net>
References: <1304963011.5005.5.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew.zaborowski@intel.com,
	oneukum@suse.de
To: dcbw@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51180
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752537Ab1EJUOs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 16:14:48 -0400
In-Reply-To: <1304963011.5005.5.camel@dcbw.foobar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Williams <dcbw@redhat.com>
Date: Mon, 09 May 2011 12:43:20 -0500

> Like other mobile broadband device ethernet interfaces, mark the LG
> VL600 with the 'wwan' devtype so userspace knows it needs additional
> configuration via the AT port before the interface can be used.
> 
> Signed-off-by: Dan Williams <dcbw@redhat.com>

Applied, thanks.
