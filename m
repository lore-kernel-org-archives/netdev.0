From: David Miller <davem@davemloft.net>
Subject: Re: ip_no_pmtu_disc and UDP
Date: Fri, 23 Oct 2015 17:44:21 -0700 (PDT)
Message-ID: <20151023.174421.845570824799930057.davem@davemloft.net>
References: <CAK3+h2wFfh+HE78kHoWwgc9vyTCLWM90C4RQ=uTRk8551-jQ7A@mail.gmail.com>
	<CAK3+h2x89hXJjK+OqnSjQEdTxDXkRsAixaL4L31SLkc7bJNMfQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: vincent.mc.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39459 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752221AbbJXA1t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2015 20:27:49 -0400
In-Reply-To: <CAK3+h2x89hXJjK+OqnSjQEdTxDXkRsAixaL4L31SLkc7bJNMfQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vincent Li <vincent.mc.li@gmail.com>
Date: Fri, 23 Oct 2015 10:01:50 -0700

>  I think the no_pmtu_disc could be renamed to pmtu_disc to be less
> confusion to users.

We cannot rename sysctl values exported to the user without breaking
things.
