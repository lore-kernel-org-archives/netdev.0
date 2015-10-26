From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH v6 1/2] geneve: implement support for IPv6-based tunnels
Date: Mon, 26 Oct 2015 12:08:31 +0800
Message-ID: <CAEP_g=9b-6LhaLja-m8GKQdjviBPNAni2P0-AivDYeKZXf9Y5A@mail.gmail.com>
References: <1445543136-8265-1-git-send-email-linville@tuxdriver.com> <1445611225-27095-1-git-send-email-linville@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, Dave Miller <davem@davemloft.net>,
	Pravin B Shelar <pshelar@nicira.com>,
	Jiri Benc <jbenc@redhat.com>,
	=?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kv5ZCJ6Jek6Iux5piO?=
	<hideaki.yoshifuji@miraclelinux.com>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f169.google.com ([209.85.160.169]:35165 "EHLO
	mail-yk0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750707AbbJZEIv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2015 00:08:51 -0400
Received: by ykaz22 with SMTP id z22so173079993yka.2
        for <netdev@vger.kernel.org>; Sun, 25 Oct 2015 21:08:51 -0700 (PDT)
In-Reply-To: <1445611225-27095-1-git-send-email-linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 23, 2015 at 10:40 PM, John W. Linville
<linville@tuxdriver.com> wrote:
> NOTE: Link-local IPv6 addresses for remote endpoints are not supported,
> since the driver currently has no capacity for binding a geneve
> interface to a specific link.
>
> Signed-off-by: John W. Linville <linville@tuxdriver.com>

Reviewed-by: Jesse Gross <jesse@nicira.com>

Thanks!

By the way, there are now some merge conflicts against current
net-next due to the merge from net.
