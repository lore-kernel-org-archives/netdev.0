From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next v2 1/9] geneve: Initialize ethernet address in
 device setup.
Date: Tue, 18 Aug 2015 17:10:09 -0700
Message-ID: <CAEP_g=-ZyNA+q1rf9VkeV=MTvf9QK4vRmYgukG-H-BYdYy15NA@mail.gmail.com>
References: <1439845905-31666-1-git-send-email-pshelar@nicira.com> <1439845905-31666-2-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f48.google.com ([209.85.215.48]:33268 "EHLO
	mail-la0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750777AbbHSAKa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Aug 2015 20:10:30 -0400
Received: by lalv9 with SMTP id v9so109635169lal.0
        for <netdev@vger.kernel.org>; Tue, 18 Aug 2015 17:10:29 -0700 (PDT)
In-Reply-To: <1439845905-31666-2-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 17, 2015 at 2:11 PM, Pravin B Shelar <pshelar@nicira.com> wrote:
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
> ---
>  drivers/net/geneve.c | 4 +---
>  1 file changed, 1 insertion(+), 3 deletions(-)

Reviewed-by: Jesse Gross <jesse@nicira.com>
