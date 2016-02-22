From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tools, bpf_asm: simplify parser rule for BPF
 extensions
Date: Mon, 22 Feb 2016 13:30:02 -0500 (EST)
Message-ID: <20160222.133002.415793448412900532.davem@davemloft.net>
References: <cda74e5d93e6e0724f94697244997e1e75ff0bdd.1456133622.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexei.starovoitov@gmail.com, ray@isc.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51743 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750953AbcBVSaH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2016 13:30:07 -0500
In-Reply-To: <cda74e5d93e6e0724f94697244997e1e75ff0bdd.1456133622.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Mon, 22 Feb 2016 11:02:40 +0100

> From: Ray Bellis <ray@isc.org>
> 
> We can already use yylval in the lexer for encoding the BPF extension
> number, so that the parser rules can be further reduced to a single one
> for each B/H/W case.
> 
> Signed-off-by: Ray Bellis <ray@isc.org>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Very nice, applied, thanks everyone.
