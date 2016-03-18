From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] Minor BPF follow-ups
Date: Fri, 18 Mar 2016 19:40:39 -0400 (EDT)
Message-ID: <20160318.194039.362601404708113767.davem@davemloft.net>
References: <cover.1458085814.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56663 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753385AbcCRXkm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Mar 2016 19:40:42 -0400
In-Reply-To: <cover.1458085814.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Wed, 16 Mar 2016 01:42:48 +0100

> Some minor last follow-ups I still had in my queue. The first one adds
> readability support for __sk_buff's tc_classid member, the remaining
> two are some minor cleanups. For details please see individual patches.

Series applied.
