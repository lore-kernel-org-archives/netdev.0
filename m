From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] filter: add minimal BPF JIT image disassembler
Date: Wed, 20 Mar 2013 15:42:24 -0400 (EDT)
Message-ID: <20130320.154224.746135766580381136.davem@davemloft.net>
References: <1363807913-4725-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32838 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751120Ab3CTTmd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Mar 2013 15:42:33 -0400
In-Reply-To: <1363807913-4725-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Wed, 20 Mar 2013 20:31:53 +0100

> This is a minimal stand-alone user space helper, that allows for debugging or
> verification of emitted BPF JIT images.

What makefile target will build this tool?
