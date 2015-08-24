From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH v3 net-next 3/8] tunnel: introduce udp_tun_rx_dst()
Date: Mon, 24 Aug 2015 15:02:22 -0700
Message-ID: <CAEP_g=89gLLPVhZLhxi2G5=rFy9Vt6k2v66UQc6c6tYj5pJqbA@mail.gmail.com>
References: <1440438195-5695-1-git-send-email-pshelar@nicira.com> <1440438195-5695-4-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f50.google.com ([209.85.215.50]:34072 "EHLO
	mail-la0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750942AbbHXWCn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Aug 2015 18:02:43 -0400
Received: by laba3 with SMTP id a3so86749229lab.1
        for <netdev@vger.kernel.org>; Mon, 24 Aug 2015 15:02:41 -0700 (PDT)
In-Reply-To: <1440438195-5695-4-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 24, 2015 at 10:43 AM, Pravin B Shelar <pshelar@nicira.com> wrote:
> Introduce function udp_tun_rx_dst() to initialize tunnel dst on
> receive path.
>
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>

Reviewed-by: Jesse Gross <jesse@nicira.com>
