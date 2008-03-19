From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [RFC] [IPv6] spelling fix in /proc:
 /proc/sys/net/ipv6/conf/default/temp_prefered_lft
Date: Wed, 19 Mar 2008 16:53:54 -0700 (PDT)
Message-ID: <20080319.165354.182584404.davem@davemloft.net>
References: <20080319204227.GF6935@ens-lyon.fr>
	<20080319.135205.125229102.davem@davemloft.net>
	<47E19F0A.1010301@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: benoit.boissinot@ens-lyon.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, pekkas@netcore.fi, yoshfuji@linux-ipv6.org
To: rick.jones2@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53114
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S943439AbYCSXxj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2008 19:53:39 -0400
In-Reply-To: <47E19F0A.1010301@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Jones <rick.jones2@hp.com>
Date: Wed, 19 Mar 2008 16:17:30 -0700

> I've not split many hairs today so I'll ask - is there _no_ way to 
> migrate a name in /proc et al?  While it may be minor to most, it would 
> seem that leaving spelling errors out where users see them doesn't 
> convey all that positive an image.

It's encoded into binaries out there, so we can really
never change these things.
