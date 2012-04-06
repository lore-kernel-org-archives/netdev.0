From: chetan loke <loke.chetan@gmail.com>
Subject: Re: [PATCH net-next V2] tcp: Fix bug when gap in rcv sequence is filled
Date: Fri, 6 Apr 2012 14:06:15 -0400
Message-ID: <CAAsGZS4w=2_e9O=cRK6r+gxirohhSPHpgkNpWw_ZvC-+Q-pHkA@mail.gmail.com>
References: <1333733810-2381-1-git-send-email-subramanian.vijay@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, ncardwell@google.com,
	ilpo.jarvinen@helsinki.fi
To: Vijay Subramanian <subramanian.vijay@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f52.google.com ([209.85.210.52]:53173 "EHLO
	mail-pz0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757167Ab2DFSGQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Apr 2012 14:06:16 -0400
Received: by dake40 with SMTP id e40so3003147dak.11
        for <netdev@vger.kernel.org>; Fri, 06 Apr 2012 11:06:15 -0700 (PDT)
In-Reply-To: <1333733810-2381-1-git-send-email-subramanian.vijay@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 6, 2012 at 1:36 PM, Vijay Subramanian
<subramanian.vijay@gmail.com> wrote:

> + =C2=A0 =C2=A0 =C2=A0 int requeued =3D 0; /*1 if an skb is requeued =
to receive_queue*/

Vijay - minor change: missing leading/trailing space in the comment.
checkpatch.pl ?


Chetan
