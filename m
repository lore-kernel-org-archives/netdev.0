From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/5] BPF updates
Date: Mon, 02 Nov 2015 22:48:59 -0500 (EST)
Message-ID: <20151102.224859.1922293945823143780.davem@davemloft.net>
References: <cover.1446126105.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@plumgrid.com, hannes@stressinduktion.org, tgraf@suug.ch,
	viro@ZenIV.linux.org.uk, ebiederm@xmission.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39173 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751968AbbKCDtB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2015 22:49:01 -0500
In-Reply-To: <cover.1446126105.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Thu, 29 Oct 2015 14:58:05 +0100

> This set adds support for persistent maps/progs. Please see
> individual patches for further details. A man-page update
> to bpf(2) will be sent later on, also a iproute2 patch for
> support in tc.
 ...
> v1 -> v2:
>   - Reworked most of patch 4 and 5
>   - Rebased to latest net-next

Series applied, thanks.
