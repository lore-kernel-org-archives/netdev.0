From: Daniel Lezcano <daniel.lezcano@linaro.org>
Subject: Re: [PATCH 1/2] clocksource: Kconfig: replace USE_OF with OF
Date: Mon, 29 Jun 2015 11:01:21 +0200
Message-ID: <55910961.1090903@linaro.org>
References: <1434541351-9699-1-git-send-email-borneo.antonio@gmail.com> <1434541351-9699-2-git-send-email-borneo.antonio@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Antonio Borneo <borneo.antonio@gmail.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:37765 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753331AbbF2JBR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jun 2015 05:01:17 -0400
Received: by wicgi11 with SMTP id gi11so65744676wic.0
        for <netdev@vger.kernel.org>; Mon, 29 Jun 2015 02:01:16 -0700 (PDT)
In-Reply-To: <1434541351-9699-2-git-send-email-borneo.antonio@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/17/2015 01:42 PM, Antonio Borneo wrote:
> USE_OF is used as intermediate Kconfig option by few
> arch's (ARM, MIPS, Xtensa); in all these cases it
> implies setting option OF too.
> Replace the only instance of USE_OF in clocksource
> with OF.
>
> Signed-off-by: Antonio Borneo <borneo.antonio@gmail.com>
> ---

Applied for 4.3

Thanks !

   -- Daniel


--=20
  <http://www.linaro.org/> Linaro.org =E2=94=82 Open source software fo=
r ARM SoCs

=46ollow Linaro:  <http://www.facebook.com/pages/Linaro> Facebook |
<http://twitter.com/#!/linaroorg> Twitter |
<http://www.linaro.org/linaro-blog/> Blog
