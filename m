From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next RESEND] test_bpf: extend tests for 32-bit
 endianness conversion
Date: Wed, 08 Jul 2015 16:20:15 -0700 (PDT)
Message-ID: <20150708.162015.1661691563042525402.davem@davemloft.net>
References: <1436389256-28483-1-git-send-email-xi.wang@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xi.wang@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38388 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751082AbbGHXUQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2015 19:20:16 -0400
In-Reply-To: <1436389256-28483-1-git-send-email-xi.wang@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xi Wang <xi.wang@gmail.com>
Date: Wed,  8 Jul 2015 14:00:56 -0700

> Currently "ALU_END_FROM_BE 32" and "ALU_END_FROM_LE 32" do not test if
> the upper bits of the result are zeros (the arm64 JIT had such bugs).
> Extend the two tests to catch this.
> 
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>
> Acked-by: Alexei Starovoitov <ast@plumgrid.com>
> Signed-off-by: Xi Wang <xi.wang@gmail.com>

Applied, thanks.
