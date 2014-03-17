From: lucien xin <lucien.xin@gmail.com>
Subject: Re: [PATCH v2] ipv6: ip6_append_data_mtu do not handle the mtu of the
 second fragment properly
Date: Mon, 17 Mar 2014 12:45:13 +0800
Message-ID: <CADvbK_cGAuXPS5d6kiLDOpxYmPPfKuhkJL0Zh1Y4ESMKwsw=Rg@mail.gmail.com>
References: <1394945457-16212-1-git-send-email-lucien.xin@gmail.com>
	<20140316232056.GD12291@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Xin Long <lucien.xin@gmail.com>,
	network dev <netdev@vger.kernel.org>,
	Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:55878 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750860AbaCQEpP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2014 00:45:15 -0400
Received: by mail-wi0-f172.google.com with SMTP id hi5so1609978wib.5
        for <netdev@vger.kernel.org>; Sun, 16 Mar 2014 21:45:13 -0700 (PDT)
In-Reply-To: <20140316232056.GD12291@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 17, 2014 at 7:20 AM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> Hi!
>
>
> While the patch looks good it does not seem to apply cleanly on net. Maybe you
> could have a look?
>

so sorry, a little mistake, post again.
