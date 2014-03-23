From: lucien xin <lucien.xin@gmail.com>
Subject: Re: [PATCH v2] ipv6: ip6_append_data_mtu do not handle the mtu of the
 second fragment properly
Date: Sun, 23 Mar 2014 16:33:19 +0800
Message-ID: <CADvbK_ciRc-1nCZcd-BzgLvLrbgCMcoHZ5gyMrkAcYunKSE36w@mail.gmail.com>
References: <1395031861-19564-1-git-send-email-lucien.xin@gmail.com>
	<20140317190534.GE12291@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Xin Long <lucien.xin@gmail.com>,
	network dev <netdev@vger.kernel.org>,
	Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f169.google.com ([74.125.82.169]:50013 "EHLO
	mail-we0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750974AbaCWIdU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Mar 2014 04:33:20 -0400
Received: by mail-we0-f169.google.com with SMTP id w62so2680976wes.0
        for <netdev@vger.kernel.org>; Sun, 23 Mar 2014 01:33:19 -0700 (PDT)
In-Reply-To: <20140317190534.GE12291@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> Fixes: 75a493e60ac4bb ("ipv6: ip6_append_data_mtu did not care about pmtudisc and frag_size")
> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
>
> Thank you!
>
hi, Hannes,

will the patch be added to -stable ?
