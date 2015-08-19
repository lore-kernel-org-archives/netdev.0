From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH v2 net-next 08/13] ipv6: ndisc: inherit metadata dst when
 creating ndisc requests
Date: Wed, 19 Aug 2015 18:47:55 +0200
Message-ID: <20150819164755.GH3635@pox.localdomain>
References: <cover.1439978875.git.jbenc@redhat.com>
 <2566fe3ffb5ae479a80d33f1eafe8072edb7f1b2.1439978875.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:35445 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751725AbbHSQr6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 12:47:58 -0400
Received: by wicne3 with SMTP id ne3so125528159wic.0
        for <netdev@vger.kernel.org>; Wed, 19 Aug 2015 09:47:57 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <2566fe3ffb5ae479a80d33f1eafe8072edb7f1b2.1439978875.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/19/15 at 12:09pm, Jiri Benc wrote:
> If output device wants to see the dst, inherit the dst of the original skb
> in the ndisc request.
> 
> This is an IPv6 counterpart of commit 0accfc268f4d ("arp: Inherit metadata
> dst when creating ARP requests").
> 
> Signed-off-by: Jiri Benc <jbenc@redhat.com>

Acked-by: Thomas Graf <tgraf@suug.ch>
