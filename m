From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bpf: add show_fdinfo handler for maps
Date: Fri, 20 Nov 2015 11:04:33 -0500 (EST)
Message-ID: <20151120.110433.2203407808829606811.davem@davemloft.net>
References: <b3f1dd7e21d72dc47beac222d655640ee584c5cd.1447930253.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32808 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751622AbbKTQEf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2015 11:04:35 -0500
In-Reply-To: <b3f1dd7e21d72dc47beac222d655640ee584c5cd.1447930253.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Thu, 19 Nov 2015 11:56:22 +0100

> Add a handler for show_fdinfo() to be used by the anon-inodes
> backend for eBPF maps, and dump the map specification there. Not
> only useful for admins, but also it provides a minimal way to
> compare specs from ELF vs pinned object.
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Applied, thanks.
