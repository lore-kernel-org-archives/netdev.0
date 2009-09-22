From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][RESEND 2] IPv6: 6rd tunnel mode
Date: Tue, 22 Sep 2009 13:45:43 -0700 (PDT)
Message-ID: <20090922.134543.158902222.davem@davemloft.net>
References: <20090922085105.GA20906@lnxos.staff.proxad.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: acassen@freebox.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45003
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753190AbZIVUpY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2009 16:45:24 -0400
In-Reply-To: <20090922085105.GA20906@lnxos.staff.proxad.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexandre Cassen <acassen@freebox.fr>
Date: Tue, 22 Sep 2009 10:51:05 +0200

> IPv6 rapid deployment (RFC5569) builds upon mechanisms of 6to4 (RFC3056)
> to enable a service provider to rapidly deploy IPv6 unicast service
> to IPv4 sites to which it provides customer premise equipment.  Like

I've read your explanation, but it is still presumptious to mention
an RFC number before it isn't really released yet.

Mention the drafts only, and when it achieves true RFC status
you can send another patch updating those references in the
code comments.
