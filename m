From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next #2 28/39] natsemi: stop using
 net_device.{base_addr, irq}.
Date: Tue, 10 Apr 2012 19:30:42 -0400 (EDT)
Message-ID: <20120410.193042.1153959183942458232.davem@davemloft.net>
References: <1333704408.git.romieu@fr.zoreil.com>
	<d13055fe45a281c97ec85454ca8e1c2bc9932166.1333704409.git.romieu@fr.zoreil.com>
	<CAAAKZwu4D6QZ02gaRQ2pmF=tLyxjefu1c=H83cxAJq2TTgdxmA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org
To: thockin@hockin.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48939 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752903Ab2DJXbr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2012 19:31:47 -0400
In-Reply-To: <CAAAKZwu4D6QZ02gaRQ2pmF=tLyxjefu1c=H83cxAJq2TTgdxmA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tim Hockin <thockin@hockin.org>
Date: Tue, 10 Apr 2012 15:53:53 -0700

> First, because I am not so involved any more, I can't say with
> certainty that these fields of struct net_device are not needed.

It's the whole basis of this patch set, and described neatly
in his "00/39" posting.
