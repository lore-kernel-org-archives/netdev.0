From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: gre: setup default multicast routes over PtP
 links
Date: Sun, 11 Oct 2015 05:33:26 -0700 (PDT)
Message-ID: <20151011.053326.2261176971034849172.davem@davemloft.net>
References: <1444321179-26425-1-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jm@jmuchemb.eu, edumazet@google.com,
	ndumazet@google.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57129 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751180AbbJKMRc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Oct 2015 08:17:32 -0400
In-Reply-To: <1444321179-26425-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Thu,  8 Oct 2015 18:19:39 +0200

> GRE point-to-point interfaces should also support ipv6 multicast. Setting
> up default multicast routes on interface creation was forgotten. Add it.
> 
> Bugzilla: <https://bugzilla.kernel.org/show_bug.cgi?id=103231>
> Cc: Julien Muchembled <jm@jmuchemb.eu>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Nicolas Dumazet <ndumazet@google.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied.
