From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] test: bpf: expand DIV_KX to DIV_MOD_KX
Date: Mon, 08 Dec 2014 20:23:37 -0500 (EST)
Message-ID: <20141208.202337.118530625154087137.davem@davemloft.net>
References: <1417428745-20199-1-git-send-email-kda@linux-powerpc.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ast@plumgrid.com
To: kda@linux-powerpc.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59020 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751103AbaLIBXj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2014 20:23:39 -0500
In-Reply-To: <1417428745-20199-1-git-send-email-kda@linux-powerpc.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Denis Kirjanov <kda@linux-powerpc.org>
Date: Mon,  1 Dec 2014 13:12:25 +0300

> Expand DIV_KX to use BPF_MOD operation in the
> DIV_KX bpf 'classic' test.
> 
> CC: Alexei Starovoitov <ast@plumgrid.com>
> Signed-off-by: Denis Kirjanov <kda@linux-powerpc.org>

Applied, thanks.
