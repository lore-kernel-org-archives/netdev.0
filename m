From: David Miller <davem@davemloft.net>
Subject: Re: incorrect tcp options with window scale
Date: Sat, 23 Aug 2008 01:18:43 -0700 (PDT)
Message-ID: <20080823.011843.88611068.davem@davemloft.net>
References: <57D3C658-5084-417D-8365-20637A3BB79B@emc.com>
	<396556a20808222026r6a262683ha803d515671d201d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: love_phil@emc.com, netdev@vger.kernel.org
To: agl@imperialviolet.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42431
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751678AbYHWISo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Aug 2008 04:18:44 -0400
In-Reply-To: <396556a20808222026r6a262683ha803d515671d201d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Adam Langley" <agl@imperialviolet.org>
Date: Fri, 22 Aug 2008 20:26:51 -0700

> David, can you hold off on this patch for a day? I think it's correct,
> but there might be another similar case with the SYNACKs that I'll
> look at once I've slept.

I was going to ignore it anyways since you didn't follow the
most basic things listed in linux/Documentation/SubmittingPatches
