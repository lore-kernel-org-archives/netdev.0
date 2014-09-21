From: YOSHIFUJI Hideaki <hideaki@yoshifuji.org>
Subject: Re: [PATCH net-next 2/8] ipv6: a bit more typesafety
Date: Sun, 21 Sep 2014 11:13:34 +0900
Message-ID: <541E344E.4040500@yoshifuji.org>
References: <cover.1411249633.git.hannes@stressinduktion.org> <fab79c190ca6d2b728a2bacb30c234c0f054e76b.1411249633.git.hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 8bit
Cc: eric.dumazet@gmail.com, vyasevich@gmail.com,
	nicolas.dichtel@6wind.com, kafai@fb.com,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:48620 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751537AbaIUCNt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2014 22:13:49 -0400
In-Reply-To: <fab79c190ca6d2b728a2bacb30c234c0f054e76b.1411249633.git.hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hannes Frederic Sowa wrote:
> Convert bool to bool and fib6_walker_t.state to the already existing enum.

Do you mean "boolean" variable (or member/type) to bool?

--yoshfuji
