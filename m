From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bpf_dbg: fix wrong register usage
Date: Wed, 30 Apr 2014 16:16:20 -0400 (EDT)
Message-ID: <20140430.161620.933043546632516787.davem@davemloft.net>
References: <1398846278-1053-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bhickey@google.com
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43654 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422664AbaD3UQV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Apr 2014 16:16:21 -0400
In-Reply-To: <1398846278-1053-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Wed, 30 Apr 2014 10:24:38 +0200

> From: Brendan Hickey <bhickey@google.com>
> 
> The AND instruction is erroneously using the X register instead
> of the K register.
> 
> Signed-off-by: Brendan Hickey <bhickey@google.com>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Applied.
