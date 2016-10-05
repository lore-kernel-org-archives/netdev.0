From: David Miller <davem@davemloft.net>
Subject: Re: net-next tree broken with CONFIG_NETFILTER_INGRESS=n
Date: Wed, 05 Oct 2016 04:01:37 -0400 (EDT)
Message-ID: <20161005.040137.1214181921027379179.davem@davemloft.net>
References: <E3004E95-F774-457E-9BA8-FA29A72BE035@holtmann.org>
        <57588F77-89EA-4BAF-8B11-E45D22B49968@holtmann.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, aconole@bytheb.org, fw@strlen.de,
        pablo@netfilter.org
To: marcel@holtmann.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35658 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752105AbcJEIBp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Oct 2016 04:01:45 -0400
In-Reply-To: <57588F77-89EA-4BAF-8B11-E45D22B49968@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcel Holtmann <marcel@holtmann.org>
Date: Wed, 5 Oct 2016 09:48:42 +0200

> I really wonder what is going on here. Normally if you break the
> build, you fix it. However it seems nobody really cares enough. If I
> am not mistaken, then this patch broke it:

The people who can work on and merge the fix are travelling and
conferencing in Tokyo right now, that's why this wasn't fixed
instantaneously.
