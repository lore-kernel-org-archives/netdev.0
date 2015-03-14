From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next v2] Configure bridge FDB ageing time using netlink.
Date: Fri, 13 Mar 2015 23:52:31 -0700
Message-ID: <CAE4R7bB2kOPMbVw3UY47p_M2-Enqy1V3+mjK+=KsYz3s8WOsfQ@mail.gmail.com>
References: <1426297229-21122-1-git-send-email-siva.mannem.lnx@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>
To: Siva Mannem <siva.mannem.lnx@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f179.google.com ([209.85.216.179]:33155 "EHLO
	mail-qc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751973AbbCNGwd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Mar 2015 02:52:33 -0400
Received: by qcyi15 with SMTP id i15so6455394qcy.0
        for <netdev@vger.kernel.org>; Fri, 13 Mar 2015 23:52:32 -0700 (PDT)
In-Reply-To: <1426297229-21122-1-git-send-email-siva.mannem.lnx@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 13, 2015 at 6:40 PM, Siva Mannem <siva.mannem.lnx@gmail.com> wrote:
> This patch allows user to configure bridge's FDB ageing using
> netlink(for ex, iproute2). Allowed range is 10 seconds to 1000000 seconds
> as per ieee8021QBridgeFdbAgingTime.
>
> Signed-off-by: Siva Mannem <siva.mannem.lnx@gmail.com>

Reviewed-by: Scott Feldman <sfeldma@gmail.com>
