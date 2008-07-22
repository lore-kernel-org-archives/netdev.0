From: Patrick McHardy <kaber@trash.net>
Subject: Re: [2.6 patch] make qdisc_class_hash_alloc() static
Date: Tue, 22 Jul 2008 19:31:27 +0200
Message-ID: <4886196F.2030001@trash.net>
References: <20080722172041.GS14846@cs181140183.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Adrian Bunk <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:37818 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752648AbYGVRba (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2008 13:31:30 -0400
In-Reply-To: <20080722172041.GS14846@cs181140183.pp.htv.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adrian Bunk wrote:
> This patch makes the needlessly global qdisc_class_hash_alloc() static.

Ack, this is not supposed to be global.
