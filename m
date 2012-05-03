From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH v4 1/3] tcp: early retransmit: tcp_enter_recovery()
Date: Wed, 2 May 2012 20:13:54 -0400
Message-ID: <CADVnQymbDLXSR=aRB8SSd8GxpsFB3j2DLCBxH-1t2oS0T+sxgA@mail.gmail.com>
References: <1336001404-21879-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, ilpo.jarvinen@helsinki.fi,
	nanditad@google.com, netdev@vger.kernel.org
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gh0-f174.google.com ([209.85.160.174]:51880 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753363Ab2ECANz convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 May 2012 20:13:55 -0400
Received: by ghrr11 with SMTP id r11so1314145ghr.19
        for <netdev@vger.kernel.org>; Wed, 02 May 2012 17:13:54 -0700 (PDT)
In-Reply-To: <1336001404-21879-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 2, 2012 at 7:30 PM, Yuchung Cheng <ycheng@google.com> wrote=
:
> This a prepartion patch that refactors the code to enter recovery
> into a new function tcp_enter_recovery(). It's needed to implement
> the delayed fast retransmit in ER.
>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> ---
> ChangeLog since v1:
> =A0- swaped with part 1 and part2
> ChangeLog since v2:
> =A0- removed RFC in commit message
> ChangeLog since v3:
> =A0- nothing

Acked-by: Neal Cardwell <ncardwell@google.com>

neal
