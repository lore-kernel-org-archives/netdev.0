From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] filter: do not output bpf image address for
 security reason
Date: Sun, 19 May 2013 23:57:00 -0700 (PDT)
Message-ID: <20130519.235700.216729402838504491.davem@davemloft.net>
References: <1368845857.3301.148.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com,
	dborkman@redhat.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54321 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753483Ab3ETG5C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 May 2013 02:57:02 -0400
In-Reply-To: <1368845857.3301.148.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 17 May 2013 19:57:37 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Do not leak starting address of BPF JIT code for non root users,
> as it might help intruders to perform an attack.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
