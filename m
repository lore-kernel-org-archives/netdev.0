From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/10] BPF updates
Date: Mon, 16 May 2016 13:49:59 -0400 (EDT)
Message-ID: <20160516.134959.1324414574261810210.davem@davemloft.net>
References: <cover.1463158442.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, elena.reshetova@intel.com,
	zlim.lnx@gmail.com, yang.shi@linaro.org,
	holzheu@linux.vnet.ibm.com, tgraf@suug.ch, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36808 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754488AbcEPRuC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2016 13:50:02 -0400
In-Reply-To: <cover.1463158442.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Fri, 13 May 2016 19:08:25 +0200

> This set implements constant blinding for BPF, first couple of
> patches are some preparatory cleanups, followed by the blinding.
> Please see individual patches for details.

Looks good, series applied.

"BPF blinding" would have been a good Subject line. :)
