From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] ip: NULL pointer dereferrence in
 tcp_v(4|6)_send_ack
Date: Wed, 01 Oct 2008 02:03:59 -0700 (PDT)
Message-ID: <20081001.020359.48616451.davem@davemloft.net>
References: <1222792151-11861-1-git-send-email-den@openvz.org>
	<20081001.015246.92774687.davem@davemloft.net>
	<200810011306.15745.vgusev@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: den@openvz.org, xemul@openvz.org, netdev@vger.kernel.org
To: vgusev@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57360
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755564AbYJAJEK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2008 05:04:10 -0400
In-Reply-To: <200810011306.15745.vgusev@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vitaliy Gusev <vgusev@openvz.org>
Date: Wed, 1 Oct 2008 13:06:15 +0400

> On 1 October 2008 12:52:46 David Miller wrote:
> > Vitaliy sent the same patch first, so I applied his copy :-)
> 
> Den's patch is not the same. My patch didn't fix IPv6 code.

Whoops... Denis can you resubmit just the ipv6 side
fix then?  I already pushed Vitaliy's commit out
to net-2.6

Thanks.
