From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] [v3] Revert Backoff on ICMP destination unreachable
Date: Tue, 01 Sep 2009 02:56:50 -0700 (PDT)
Message-ID: <20090901.025650.253394803.davem@davemloft.net>
References: <4A950B76.1070002@tvk.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: damian@tvk.rwth-aachen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45482
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752817AbZIAJ4g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2009 05:56:36 -0400
In-Reply-To: <4A950B76.1070002@tvk.rwth-aachen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Damian Lukowski <damian@tvk.rwth-aachen.de>
Date: Wed, 26 Aug 2009 12:16:22 +0200

> This series of patches implements the TCP improvement of the Internet Draft
> "Make TCP more Robust to Long Connectivity Disruptions"
> (http://tools.ietf.org/html/draft-zimmermann-tcp-lcd).

All applied to net-next-2.6, thanks!
