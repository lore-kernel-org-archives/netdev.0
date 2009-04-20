From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] irda: convert pxaficp device to net_device_ops
Date: Mon, 20 Apr 2009 03:06:53 -0700 (PDT)
Message-ID: <20090420.030653.135452363.davem@davemloft.net>
References: <1240062266-4339-1-git-send-email-dbaryshkov@gmail.com>
	<20090419102540.GA3373@psychotron.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dbaryshkov@gmail.com, samuel@sortiz.org, netdev@vger.kernel.org
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54785
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754267AbZDTKHD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Apr 2009 06:07:03 -0400
In-Reply-To: <20090419102540.GA3373@psychotron.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Sun, 19 Apr 2009 12:25:41 +0200

> Sat, Apr 18, 2009 at 03:44:26PM CEST, dbaryshkov@gmail.com wrote:
>>Signed-off-by: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
 ...
> Patch looks, only little nitpick - why two blank lines here ^ ?

Also, net-next-2.6 already has this driver converted.
