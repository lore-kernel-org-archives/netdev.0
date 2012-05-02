From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH v3 1/3] tcp: early retransmit: tcp_enter_recovery()
Date: Wed, 2 May 2012 15:03:53 -0400
Message-ID: <CADVnQymqUj_cyDrcpMf81zaztOnWgTCXqLngrgtVe=NT75k+bw@mail.gmail.com>
References: <1335984391-31340-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, ilpo.jarvinen@helsinki.fi,
	nanditad@google.com, netdev@vger.kernel.org
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:37472 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753405Ab2EBTDy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2012 15:03:54 -0400
Received: by yenm10 with SMTP id m10so521399yen.19
        for <netdev@vger.kernel.org>; Wed, 02 May 2012 12:03:53 -0700 (PDT)
In-Reply-To: <1335984391-31340-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 2, 2012 at 2:46 PM, Yuchung Cheng <ycheng@google.com> wrote=
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

Acked-by: Neal Cardwell <ncardwell@google.com>

neal
