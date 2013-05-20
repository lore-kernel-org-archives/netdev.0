From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] ppc: bpf_jit: can call module_free() from
 any context
Date: Mon, 20 May 2013 14:04:19 -0700 (PDT)
Message-ID: <20130520.140419.486518267033616045.davem@davemloft.net>
References: <1369073151-25028-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, viro@zeniv.linux.org.uk, matt@ozlabs.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37972 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756429Ab3ETVEU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 May 2013 17:04:20 -0400
In-Reply-To: <1369073151-25028-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Mon, 20 May 2013 20:05:50 +0200

> Followup patch on module_free()/vfree() that takes care of the rest, so
> no longer this workaround with work_struct is needed.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Applied.
