From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] BPF updates
Date: Sat, 09 May 2015 17:33:38 -0400 (EDT)
Message-ID: <20150509.173338.601953074860996531.davem@davemloft.net>
References: <cover.1430908145.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@plumgrid.com, keescook@chromium.org, nschichan@freebox.fr,
	netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45684 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751510AbbEIVdn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2015 17:33:43 -0400
In-Reply-To: <cover.1430908145.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Wed,  6 May 2015 16:12:26 +0200

> This set gets rid of BPF special handling in seccomp filter preparation
> and provides generic infrastructure from BPF side, which eventually also
> allows for classic BPF JITs to add support for seccomp filters.

I'll apply this series, thanks.
