From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: Re: [PATCH net-next V2] tcp: Fix bug when gap in rcv sequence is filled
Date: Fri, 6 Apr 2012 11:27:44 -0700
Message-ID: <CAGK4HS-FZ038=Yik4DEQ26y4-9Zx9Gp80CU5_JS0U-anxjh9Wg@mail.gmail.com>
References: <1333733810-2381-1-git-send-email-subramanian.vijay@gmail.com>
	<CAAsGZS4w=2_e9O=cRK6r+gxirohhSPHpgkNpWw_ZvC-+Q-pHkA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, ncardwell@google.com,
	ilpo.jarvinen@helsinki.fi
To: chetan loke <loke.chetan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f46.google.com ([209.85.212.46]:50948 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753473Ab2DFS1o convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Apr 2012 14:27:44 -0400
Received: by vbbff1 with SMTP id ff1so1335018vbb.19
        for <netdev@vger.kernel.org>; Fri, 06 Apr 2012 11:27:44 -0700 (PDT)
In-Reply-To: <CAAsGZS4w=2_e9O=cRK6r+gxirohhSPHpgkNpWw_ZvC-+Q-pHkA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> + =A0 =A0 =A0 int requeued =3D 0; /*1 if an skb is requeued to recei=
ve_queue*/
>
> Vijay - minor change: missing leading/trailing space in the comment.
> checkpatch.pl ?

Thanks for the reviews Chetan. checkpatch.pl reported no errors and no
warnings however.
I will wait for additional feedback from TCP folks and send version V3
if needed.

Thanks,
Vijay
