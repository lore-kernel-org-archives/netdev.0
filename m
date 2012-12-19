From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] bridge: Correctly encode addresses when dumping mdb
 entries
Date: Wed, 19 Dec 2012 07:11:26 +0000 (UTC)
Message-ID: <karpau$s7f$1@ger.gmane.org>
References: <1355867648-17316-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:58173 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751110Ab2LSHLm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Dec 2012 02:11:42 -0500
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1TlDom-0005Hg-Eo
	for netdev@vger.kernel.org; Wed, 19 Dec 2012 08:11:52 +0100
Received: from 112.122.183.103 ([112.122.183.103])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 19 Dec 2012 08:11:52 +0100
Received: from xiyou.wangcong by 112.122.183.103 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 19 Dec 2012 08:11:52 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 18 Dec 2012 at 21:54 GMT, Vlad Yasevich <vyasevic@redhat.com> wrote:
> When dumping mdb table, set the addresses the kernel returns
> based on the address protocol type.
>
> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>

Looks good.

Acked-by: Cong Wang <amwang@redhat.com>
