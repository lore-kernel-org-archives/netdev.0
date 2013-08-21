From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 2/4] netxen: lower NAPI weight
Date: Wed, 21 Aug 2013 22:16:05 +0400
Message-ID: <521503E5.1080003@cogentembedded.com>
References: <1377103771-1590-1-git-send-email-mschmidt@redhat.com> <1377103771-1590-3-git-send-email-mschmidt@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>,
	Manish Chopra <manish.chopra@qlogic.com>,
	Sony Chacko <sony.chacko@qlogic.com>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>
To: Michal Schmidt <mschmidt@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f173.google.com ([209.85.217.173]:57503 "EHLO
	mail-lb0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752696Ab3HUSP7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Aug 2013 14:15:59 -0400
Received: by mail-lb0-f173.google.com with SMTP id 10so880622lbf.18
        for <netdev@vger.kernel.org>; Wed, 21 Aug 2013 11:15:58 -0700 (PDT)
In-Reply-To: <1377103771-1590-3-git-send-email-mschmidt@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/21/2013 08:49 PM, Michal Schmidt wrote:

> Since commit 82dc3c63 netif_napi_add() produces an error message if

    Likewise, need summary line in parens.

> a NAPI poll weight greater than 64 is requested.

> Use the standard NAPI weight.

> Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
> CC: Manish Chopra <manish.chopra@qlogic.com>
> CC: Sony Chacko <sony.chacko@qlogic.com>
> CC: Rajesh Borundia <rajesh.borundia@qlogic.com>

WBR, Sergei
