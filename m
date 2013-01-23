From: Eric Dumazet <erdnetdev@gmail.com>
Subject: Re: [Patch net-next] net: add RCU annotation to sk_dst_cache field
Date: Tue, 22 Jan 2013 21:34:51 -0800
Message-ID: <1358919291.12374.735.camel@edumazet-glaptop>
References: <1358916229-19004-1-git-send-email-amwang@redhat.com>
	 <1358916659.12374.684.camel@edumazet-glaptop>
	 <1358917086.4235.12.camel@cr0>
	 <1358917603.12374.713.camel@edumazet-glaptop>
	 <1358919057.4235.17.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:47495 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750703Ab3AWFez (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2013 00:34:55 -0500
Received: by mail-pa0-f48.google.com with SMTP id fa1so4548194pad.21
        for <netdev@vger.kernel.org>; Tue, 22 Jan 2013 21:34:55 -0800 (PST)
In-Reply-To: <1358919057.4235.17.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-01-23 at 13:30 +0800, Cong Wang wrote:

> 
> I expect most of them are from decnet, which is (partially) deprecated?

How many answers to you want exactly from me ?
