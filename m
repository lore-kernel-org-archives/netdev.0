From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH net-next v1 0/6] bonding: remove bond->vlan_list
Date: Thu, 8 Aug 2013 18:49:49 +0200
Message-ID: <20130808164949.GU22756@redhat.com>
References: <1375957269-13100-1-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Nikolay Aleksandrov <nikolay@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:26028 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757988Ab3HHQut (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Aug 2013 12:50:49 -0400
Content-Disposition: inline
In-Reply-To: <1375957269-13100-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 08, 2013 at 12:21:03PM +0200, Veaceslav Falico wrote:
>RFC -> v1: Got some feedback from Nikolay Aleksandrov (privately), tried to
>	   address it, also fixed some bugs that I've found on the way. I
>	   think it's ready to be considered a patchset for
>	   review/inclusion in net-next.

Got some more feedback and spotted some bugs, will send a full v2 shortly.
