From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/6] netns: port linux-vrf features to network
 namespaces
Date: Tue, 28 Oct 2008 16:03:47 -0700 (PDT)
Message-ID: <20081028.160347.184188752.davem@davemloft.net>
References: <49074D7C.7010505@thomson.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, benjamin.thery@bull.net,
	jleu@mindspring.com, linux-vrf-general@lists.sourceforge.net
To: vivien.chappelier@thomson.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54306
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753061AbYJ1XEK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2008 19:04:10 -0400
In-Reply-To: <49074D7C.7010505@thomson.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vivien Chappelier <vivien.chappelier@thomson.net>
Date: Tue, 28 Oct 2008 18:35:56 +0100

>     The recently introduced network namespaces allow separate
>     standalone network stacks to coexist on the same machine. This
>     is a very useful functionality that we have been using in our
>     products for some time, through the VRF patchset
>     (http://linux-vrf.sourceforge.net/). The goal of the VRF
>     patchset and network namespaces are very similar, yet some
>     features of the VRF are missing that these patches intend to
>     provide.

I'll leave it up to the namespace folks to review this and decide whether
it makes sense to consider these changes seriously or not.
