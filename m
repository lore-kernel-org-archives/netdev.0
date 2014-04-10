From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Does IPv6 support Jumbograms ?
Date: Thu, 10 Apr 2014 07:01:15 -0700
Message-ID: <1397138475.16584.27.camel@edumazet-glaptop2.roam.corp.google.com>
References: <5345A2B3.7040602@gmail.com>
	 <1397079665.16584.17.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140409223546.GH27255@order.stressinduktion.org>
	 <1397090170.16584.21.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140410132842.GI27255@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Francois WELLENREITER <f.wellenreiter@gmail.com>,
	netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:43372 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933829AbaDJOBR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2014 10:01:17 -0400
Received: by mail-pa0-f43.google.com with SMTP id bj1so4018199pad.2
        for <netdev@vger.kernel.org>; Thu, 10 Apr 2014 07:01:17 -0700 (PDT)
In-Reply-To: <20140410132842.GI27255@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-04-10 at 15:28 +0200, Hannes Frederic Sowa wrote:

> I thought ip6_default_advmss will deal with this which correctly limits the
> mtu. Capping dst_mtu would make it harder to implement jumbograms some day.

I doubt we'll do this (jumbo grams)

This is a terrible academic idea.
