From: "Joonwoo Park" <joonwpark81@gmail.com>
Subject: Re: [PATCH 0/5]: [VLAN] fixes for PACKET
Date: Fri, 11 Apr 2008 23:05:47 +0900
Message-ID: <b25c3fa70804110705x74e11b5bm2835a558dcf759bf@mail.gmail.com>
References: <20080411092523.GA6873@tp64> <47FF61D6.3090206@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: auke-jan.h.kok@intel.com, davem@davemloft.net, jeff@garzik.org,
	netdev@vger.kernel.org
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.238]:41309 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759183AbYDKOFv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Apr 2008 10:05:51 -0400
Received: by wr-out-0506.google.com with SMTP id c48so555283wra.1
        for <netdev@vger.kernel.org>; Fri, 11 Apr 2008 07:05:48 -0700 (PDT)
In-Reply-To: <47FF61D6.3090206@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2008/4/11, Patrick McHardy <kaber@trash.net>:
> Joonwoo Park wrote:
> > Hi,
> > This patchset is the v3 for resolving the issue about VLAN & PACKET.
> > It contains some cleanups for vlan as well.
> >
> > Related previous discussions are below:
> > http://bugzilla.kernel.org/show_bug.cgi?id=8218
> >
> http://thread.gmane.org/gmane.linux.drivers.e1000.devel/2587
> > http://thread.gmane.org/gmane.linux.network/88488
> >
> > [PATCH 1/5] [VLAN]: Unclassified vlan packet
> > [PATCH 2/5] [VLAN]: Add vlan tag into PACKET_AUXDATA
> > [PATCH 3/5] [VLAN]: Use is_vlan_dev()
> > [PATCH 4/5] [E1000]: [VLAN] Turn off the HW vlan filter if promisc
> > [PATCH 5/5] [E1000e]: [VLAN] Turn off the HW vlan filter if promisc
> >
> > Thanks Patrick for the suggestions.
> >
> > Please review and consider applying.
> >
>
>
> Your patches don't seem to have made it to the list or my inbox.
>

It weird :(
I've resent all of them with another mail client.
Thanks for notification.

Joonwoo,
