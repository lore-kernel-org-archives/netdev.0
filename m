From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] net: Marking struct pernet_operations __net_initdata was inappropriate
Date: Sat, 27 Oct 2007 00:07:12 -0600
Message-ID: <m1zly5rsz3.fsf@ebiederm.dsl.xmission.com>
References: <4721D283.4050909@bull.net>
	<20071026.045503.62376243.davem@davemloft.net>
	<m1hckdwici.fsf_-_@ebiederm.dsl.xmission.com>
	<20071026.225516.152502425.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: benjamin.thery@bull.net, netdev@vger.kernel.org, dlunev@gmail.com,
	containers@lists.osdl.org, clg@fr.ibm.com, xemul@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:51901 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751711AbXJ0GId (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Oct 2007 02:08:33 -0400
In-Reply-To: <20071026.225516.152502425.davem@davemloft.net> (David Miller's
	message of "Fri, 26 Oct 2007 22:55:16 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:
>
> Applied, thanks Eric.
>
> Although juding by his comments I though that Denis had different
> plans in mind to fix this.

He might.  Somehow I wasn't on that thread so I missed it until after
I sent this patch.  Reading through that thread  again it looks like
he had a thought for another attribute.  It all sounded very clever.

This patch is minimal stupid and should just work.  Doubtless the
clever patch can be applied on top, once the details are figured
out.

Eric
