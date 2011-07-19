From: =?UTF-8?Q?Am=C3=A9rico_Wang?= <xiyou.wangcong@gmail.com>
Subject: Re: [Patch] bluetooth: make 3 functions in hci_conn.c static
Date: Tue, 19 Jul 2011 15:29:38 +0800
Message-ID: <CAM_iQpXSzrLCitF364MadxkQ3G-4botpydOmZhKxfhMbT7uweQ@mail.gmail.com>
References: <CAM_iQpUHynJZBJ29qeu_fv4Rko0=7chE5BrhavOKVyzaTDf28A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-bluetooth@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	"Gustavo F. Padovan" <padovan@profusion.mobi>,
	Marcel Holtmann <marcel@holtmann.org>
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:52396 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752177Ab1GSH3j convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jul 2011 03:29:39 -0400
In-Reply-To: <CAM_iQpUHynJZBJ29qeu_fv4Rko0=7chE5BrhavOKVyzaTDf28A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 19, 2011 at 3:18 PM, Am=C3=A9rico Wang <xiyou.wangcong@gmai=
l.com> wrote:
> hci_acl_connect()
> hci_add_sco()
> hci_conn_enter_sniff_mode()
>
> these three functions can become static as there are no callers outsi=
de.
>

Self-NAK.

Seems these 3 functions have no callers just accidentally.
