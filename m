From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH 1/1 v2 net-next] net: fec: fix the build as module
Date: Sat, 23 Mar 2013 15:12:06 -0300
Message-ID: <CAOMZO5Cn4xG38fB9snS2cJSjZDzaWQJSGLp3+hFyxTXmOkO7BQ@mail.gmail.com>
References: <1363915193-22179-1-git-send-email-Frank.Li@freescale.com>
	<CAOMZO5D1p-QJ=7N-QrLbjcwK0b=280QEFuxNkbmYsmTeRitv+w@mail.gmail.com>
	<CAHrpEqQU9e-qAYvtHmB9bDhXafHmG=yWJxxv96f94FxVq9QYgQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Frank Li <Frank.Li@freescale.com>, u.kleine-koenig@pengutronix.de,
	netdev@vger.kernel.org, davem@davemloft.net,
	linux-arm-kernel@lists.infradead.org
To: Frank Li <lznuaa@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f45.google.com ([209.85.212.45]:46203 "EHLO
	mail-vb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751622Ab3CWSMH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Mar 2013 14:12:07 -0400
Received: by mail-vb0-f45.google.com with SMTP id q16so853323vbe.4
        for <netdev@vger.kernel.org>; Sat, 23 Mar 2013 11:12:06 -0700 (PDT)
In-Reply-To: <CAHrpEqQU9e-qAYvtHmB9bDhXafHmG=yWJxxv96f94FxVq9QYgQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 21, 2013 at 11:39 PM, Frank Li <lznuaa@gmail.com> wrote:
>>
>> This error does not not happen in 'net-next' anymore.
>
> what's your suggestion? change commit message or request apply to 3.9

Your motivation now is to generate a single kernel module instead of
two for the fec, rather than fixing the the build error.

So you need to adjust the Subject and commit log.

I am not sure if we really need to rename fec.c though.
