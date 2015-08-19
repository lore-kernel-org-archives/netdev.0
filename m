From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next v2 4/9] geneve: Make dst-port configurable.
Date: Tue, 18 Aug 2015 17:27:14 -0700
Message-ID: <CAEP_g=8bAqZxdjKAX+AsuA0+xnoYMv27Ny0Kp0y5oUUgNGStyQ@mail.gmail.com>
References: <1439845905-31666-1-git-send-email-pshelar@nicira.com> <1439845905-31666-5-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f170.google.com ([209.85.217.170]:33386 "EHLO
	mail-lb0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750822AbbHSA1g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Aug 2015 20:27:36 -0400
Received: by lbbsx3 with SMTP id sx3so113582996lbb.0
        for <netdev@vger.kernel.org>; Tue, 18 Aug 2015 17:27:34 -0700 (PDT)
In-Reply-To: <1439845905-31666-5-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 17, 2015 at 2:11 PM, Pravin B Shelar <pshelar@nicira.com> wrote:
> Add netlink interface to configure Geneve UDP port number.
> So that user can configure it for a Gevene device.
>
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>

Reviewed-by: Jesse Gross <jesse@nicira.com>
