From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/16] mib: finish with ipv4 mibs netnsization
Date: Fri, 18 Jul 2008 04:09:25 -0700 (PDT)
Message-ID: <20080718.040925.261545164.davem@davemloft.net>
References: <487F46CD.7090103@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39724
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751786AbYGRLJZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jul 2008 07:09:25 -0400
In-Reply-To: <487F46CD.7090103@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Thu, 17 Jul 2008 17:19:09 +0400

> This is the notorious "finalizing set" - after this all the ipv4
> stats are isolated from each other. The ipv6, dccp and sctp I
> touched with previous sets deserve special handling and will be
> done in 2.6.28
> 
> No *new* stuff for 2.6.27 from me, thank you Dave for your patience :)
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

All applied, thanks Pavel.

I keep hearing noises that some day sysfs+ns will work, is that something
we'll see in 2.6.27 possibly?  That would help my own build validation
and testing of changes.

