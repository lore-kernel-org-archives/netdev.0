From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 0/2] net: finalize multicast list
 conversion
Date: Sat, 03 Apr 2010 14:23:27 -0700 (PDT)
Message-ID: <20100403.142327.34964493.davem@davemloft.net>
References: <20100402072126.GA3100@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54017
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755944Ab0DCVX0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Apr 2010 17:23:26 -0400
In-Reply-To: <20100402072126.GA3100@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Fri, 2 Apr 2010 09:21:27 +0200

> This patchset finalizes the conversion of multicast list to list_head. It also
> moves the code manipulating all address lists to it's own file.

Both applied, thanks Jiri.
