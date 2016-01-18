From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] arm64: insn: remove BUG_ON from codegen
Date: Sun, 17 Jan 2016 19:15:15 -0500 (EST)
Message-ID: <20160117.191515.1256557824840537819.davem@davemloft.net>
References: <1452756802-16511-1-git-send-email-zlim.lnx@gmail.com>
	<20160115170852.GB1641@arm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zlim.lnx@gmail.com, ast@kernel.org, catalin.marinas@arm.com,
	rabin@rab.in, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: will.deacon@arm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33567 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752892AbcARAPS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Jan 2016 19:15:18 -0500
In-Reply-To: <20160115170852.GB1641@arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Will Deacon <will.deacon@arm.com>
Date: Fri, 15 Jan 2016 17:08:53 +0000

>   Acked-by: Will Deacon <will.deacon@arm.com>

Please do not indent Acked-by: tags like this, it must appear
on the very first column of the line or else automated tools
and things like patchwork will not pick it up properly.

I fixed it up by hand this time, but if you continue to do
this I may make mistakes and miss it in the future and besides
you're making more work for me.

Thanks.
