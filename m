From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5 00/15] some netpoll and netconsole fixes
Date: Tue, 14 Aug 2012 14:41:09 -0700 (PDT)
Message-ID: <20120814.144109.1201268622871835836.davem@davemloft.net>
References: <1344597891-32242-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38400 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752122Ab2HNVlK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Aug 2012 17:41:10 -0400
In-Reply-To: <1344597891-32242-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Fri, 10 Aug 2012 19:24:36 +0800

> This patchset fixes serval problems in netconsole and netpoll.
> 
> I ran this patchset in my KVM guest with some netpoll test cases,
> even covered with some corner cases, everything worked as expected.

Ok looks good, applied to 'net', thanks.
