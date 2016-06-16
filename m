From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] bpf: improve fd array release
Date: Wed, 15 Jun 2016 23:43:12 -0700 (PDT)
Message-ID: <20160615.234312.1730174536154901684.davem@davemloft.net>
References: <cover.1466021686.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37117 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751275AbcFPGnN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 02:43:13 -0400
In-Reply-To: <cover.1466021686.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Wed, 15 Jun 2016 22:47:11 +0200

> This set improves BPF perf fd array map release wrt to purging
> entries, first two extend the API as needed. Please see individual
> patches for more details.

Series applied, thanks Daniel.
