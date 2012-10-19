From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH 1/3] skbtrace v2: core feature and common events
Date: Fri, 19 Oct 2012 07:30:59 +0000 (UTC)
Message-ID: <k5qvji$v6v$1@ger.gmane.org>
References: <5080F031.5040804@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:40506 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751701Ab2JSHbQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Oct 2012 03:31:16 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1TP739-000143-H4
	for netdev@vger.kernel.org; Fri, 19 Oct 2012 09:31:19 +0200
Received: from 112.122.181.103 ([112.122.181.103])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 19 Oct 2012 09:31:19 +0200
Received: from xiyou.wangcong by 112.122.181.103 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 19 Oct 2012 09:31:19 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 19 Oct 2012 at 06:16 GMT, Li Yu <raise.sail@gmail.com> wrote:
> From: Li Yu <bingtian.ly@taobao.com>
>
> This patch contains:
>
> 1. The glue code of tracepoints subsystem and relay file system.
> 2. API for particular networking trace points.
> 3. The skb_rps_info trace point.
>


Any reason why not split it into three patches?
