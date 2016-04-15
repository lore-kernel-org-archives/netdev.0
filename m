From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5] BPF updates
Date: Thu, 14 Apr 2016 21:37:15 -0400 (EDT)
Message-ID: <20160414.213715.1135822988394354951.davem@davemloft.net>
References: <cover.1460497071.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, tgraf@suug.ch, bblanco@plumgrid.com,
	brendan.d.gregg@gmail.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42557 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751375AbcDOBhS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 21:37:18 -0400
In-Reply-To: <cover.1460497071.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Wed, 13 Apr 2016 00:10:49 +0200

> This series adds a new verifier argument type called
> ARG_PTR_TO_RAW_STACK and converts related helpers to make
> use of it. Basic idea is that we can save init of stack
> memory when the helper function is guaranteed to fully
> fill out the passed buffer in every path. Series also adds
> test cases and converts samples. For more details, please
> see individual patches.

Series applied, thanks.
