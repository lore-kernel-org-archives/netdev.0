From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Marking struct pernet_operations __net_initdata
 was inappropriate
Date: Sat, 27 Oct 2007 00:29:43 -0700 (PDT)
Message-ID: <20071027.002943.40590861.davem@davemloft.net>
References: <m1hckdwici.fsf_-_@ebiederm.dsl.xmission.com>
	<20071026.225516.152502425.davem@davemloft.net>
	<m1zly5rsz3.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: benjamin.thery@bull.net, netdev@vger.kernel.org, dlunev@gmail.com,
	containers@lists.osdl.org, clg@fr.ibm.com, xemul@openvz.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44456
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751042AbXJ0H3l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Oct 2007 03:29:41 -0400
In-Reply-To: <m1zly5rsz3.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Sat, 27 Oct 2007 00:07:12 -0600

> This patch is minimal stupid and should just work.  Doubtless the
> clever patch can be applied on top, once the details are figured
> out.

That is true and that's why I applied your patch.

Thanks!
