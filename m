From: Chen Gang <gang.chen@asianux.com>
Subject: Re: [Suggestion] drivers/isdn: about the loop after call isdn_tty_send_msg
Date: Wed, 27 Feb 2013 18:08:18 +0800
Message-ID: <512DDB12.9030008@asianux.com>
References: <512DD2B3.2070404@asianux.com> <512DD94C.2020008@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jiri Kosina <jkosina@suse.cz>, isdn@linux-pingi.de,
	Greg KH <gregkh@linuxfoundation.org>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	netdev <netdev@vger.kernel.org>
To: Jiri Slaby <jslaby@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:29435 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751792Ab3B0KIg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Feb 2013 05:08:36 -0500
In-Reply-To: <512DD94C.2020008@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2013=E5=B9=B402=E6=9C=8827=E6=97=A5 18:00, Jiri Slaby =E5=86=99=
=E9=81=93:
> Nope, we should break the for loop because isdn_tty_send_msg is inten=
ded
> to eat the rest of the string. Evidently nobody tested this path yet.

  thank you for your reply.

  I will send relative patch, tomorrow. please help to check, thanks.

  :-)

--=20
Chen Gang

Asianux Corporation
