From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/7] bpf: introduce direct packet access
Date: Fri, 06 May 2016 16:02:10 -0400 (EDT)
Message-ID: <20160506.160210.336273886152008913.davem@davemloft.net>
References: <1462502955-1731797-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, netdev@vger.kernel.org, kernel-team@fb.com
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49037 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758152AbcEFUCM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 May 2016 16:02:12 -0400
In-Reply-To: <1462502955-1731797-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@fb.com>
Date: Thu, 5 May 2016 19:49:08 -0700

> This set of patches introduce 'direct packet access' from
> cls_bpf and act_bpf programs (which are root only).

Series applied, thanks Alexei.
