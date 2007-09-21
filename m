From: "Marco Berizzi" <pupilla@hotmail.com>
Subject: Re: wrong arp query with policy routing
Date: Fri, 21 Sep 2007 11:08:05 +0200
Message-ID: <BAY103-DAV1014588479A3FF5B66EEDDB2BB0@phx.gbl>
References: <BAY103-DAV2BC129A14C4A29986CC0CB2B80@phx.gbl> <BAY103-DAV12BF0DF9E47B1577FB9814B2B90@phx.gbl> <46F29741.2030505@redhat.com>
Cc: <netdev@vger.kernel.org>
To: "Chuck Ebbert" <cebbert@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay0-omc2-s24.bay0.hotmail.com ([65.54.246.160]:58631 "EHLO
	bay0-omc2-s24.bay0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750753AbXIUJIV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2007 05:08:21 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chuck Ebbert wrote:

> > Is there a way to force linux to make an arp
> > probe with the source ip belonging to the
> > same subnet requesting ip?
>
> Umm, arp_filter?

Hello Chuck,

thanks for the reply.
I have tried to 'echo 1 > /proc/sys/net/ipv4/conf/eth0',
but the 'arp whos-has' behaviour doesn't change.
Other hints?


