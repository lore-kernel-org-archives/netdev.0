From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] ifb: add multi-queue support
Date: Thu, 12 Nov 2009 16:11:35 +0100
Message-ID: <4AFC25A7.10301@trash.net>
References: <4AFA8911.7050204@gmail.com> <4AFBD911.6000900@gmail.com> <412e6f7f0911120148r48fa553bt610e013d96522a3d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59373 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753092AbZKLPIG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Nov 2009 10:08:06 -0500
In-Reply-To: <412e6f7f0911120148r48fa553bt610e013d96522a3d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changli Gao wrote:
> The corresponding iprout2 patch is attached.

Printing the value during dumps is missing from this patch.
