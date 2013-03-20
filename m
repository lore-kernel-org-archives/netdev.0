From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next 4/4] filter: add minimal BPF JIT emitted
 image disassembler
Date: Wed, 20 Mar 2013 13:17:13 -0400 (EDT)
Message-ID: <20130320.131713.988538863586629681.davem@davemloft.net>
References: <1363711172-9728-1-git-send-email-dborkman@redhat.com>
	<1363711172-9728-5-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, edumazet@google.com
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58942 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751222Ab3CTRRQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Mar 2013 13:17:16 -0400
In-Reply-To: <1363711172-9728-5-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Tue, 19 Mar 2013 17:39:32 +0100

> This is a minimal stand-alone user space helper, that allows for debugging or
> verification of emitted BPF JIT images.

As Ben Hutchings suggested, please respin this such that the tool
goes somewhere under tools/

Creating a tools/net/ subdirectory for small programs like this is
fine.

Thanks!
