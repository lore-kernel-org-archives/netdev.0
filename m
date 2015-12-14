From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sched/cls_flow.c
Date: Mon, 14 Dec 2015 14:12:51 -0500 (EST)
Message-ID: <20151214.141251.1256607903523580851.davem@davemloft.net>
References: <CADo-kff8vOq8YzvB8R+LOCUyfhx9+=QRhsLLa-eP9M+i3m5rcQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com
To: i.o.gavrilov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58798 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932077AbbLNTMx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Dec 2015 14:12:53 -0500
In-Reply-To: <CADo-kff8vOq8YzvB8R+LOCUyfhx9+=QRhsLLa-eP9M+i3m5rcQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Igor Gavrilov <i.o.gavrilov@gmail.com>
Date: Mon, 14 Dec 2015 10:43:35 +0200

> From: Igor Gavrilov <i.o.gavrilov@gmail.com>
> 
> Improved CTTUPLE macro with code from sched/act_connmark.c, so it be
> able to get unNATed addresses from nf_conntrack on ingress interface.
> 
> Signed-off-by: Igor Gavrilov <i.o.gavrilov@gmail.com>
> Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

Your patch was mangled by your email client.

Please email a test patch to yourself, and DO NOT try to resubmit this patch
to the mailing list until you can successfully apply the patch you receive
in that test email.
