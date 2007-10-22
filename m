From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: kernel panic when running tcpdump
Date: Mon, 22 Oct 2007 12:03:59 -0700
Message-ID: <20071022120359.26403bf0.akpm@linux-foundation.org>
References: <20071011213126.cf92efb7.akpm@linux-foundation.org>
	<200710222040.19921.m.kozlowski@tuxland.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-ppp@vger.kernel.org
To: Mariusz Kozlowski <m.kozlowski@tuxland.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:50319 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752221AbXJVTEN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2007 15:04:13 -0400
In-Reply-To: <200710222040.19921.m.kozlowski@tuxland.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 22 Oct 2007 20:40:18 +0200 Mariusz Kozlowski <m.kozlowski@tuxland.pl> wrote:

> 	I'm seeing reproducible oops on 2.6.23-mm1 when trying to run tcpdump
> over ppp0 interface.

Can you please test the latest Linus kernel from
ftp://ftp.kernel.org/pub/linux/kernel/v2.6/snapshots/?

Because all netwrking things which were in 2.6.23-mm1 are now in mainline.
So if mainline is OK then that bug presumably got fixed.

Thanks.

