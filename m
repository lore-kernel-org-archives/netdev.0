From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] arm: bpf_jit: can call module_free() from
 any context
Date: Mon, 20 May 2013 14:04:24 -0700 (PDT)
Message-ID: <20130520.140424.606127019175307083.davem@davemloft.net>
References: <1369073151-25028-1-git-send-email-dborkman@redhat.com>
	<1369073151-25028-2-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, viro@zeniv.linux.org.uk, mgherzan@gmail.com
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37978 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756561Ab3ETVEZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 May 2013 17:04:25 -0400
In-Reply-To: <1369073151-25028-2-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Mon, 20 May 2013 20:05:51 +0200

> Follow-up on module_free()/vfree() that takes care of the rest, so no
> longer this workaround with work_struct needed.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Applied.
