From: Chen Gang <gang.chen@asianux.com>
Subject: Re: [PATCH] drivers/isdn: beautify code, delete 'break' after 'return'
Date: Fri, 15 Mar 2013 10:04:41 +0800
Message-ID: <514281B9.7000105@asianux.com>
References: <512DCE3B.3050107@asianux.com> <512DCEDC.4030500@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Greg KH <gregkh@linuxfoundation.org>, alan@linux.intel.com,
	netdev <netdev@vger.kernel.org>
To: Jiri Kosina <jkosina@suse.cz>, isdn@linux-pingi.de,
	Jiri Slaby <jslaby@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:2120 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751970Ab3COCFH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Mar 2013 22:05:07 -0400
In-Reply-To: <512DCEDC.4030500@asianux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Maintainers:

  is it patch ok ?

  thanks.

=D3=DA 2013=C4=EA02=D4=C227=C8=D5 17:16, Chen Gang =D0=B4=B5=C0:
>=20
>   delete 'break' statement after 'return' statement
>=20
> Signed-off-by: Chen Gang <gang.chen@asianux.com>
> ---
>  drivers/isdn/i4l/isdn_tty.c |    1 -
>  1 files changed, 0 insertions(+), 1 deletions(-)
>=20
> diff --git a/drivers/isdn/i4l/isdn_tty.c b/drivers/isdn/i4l/isdn_tty.=
c
> index d8a7d83..925a7ed 100644
> --- a/drivers/isdn/i4l/isdn_tty.c
> +++ b/drivers/isdn/i4l/isdn_tty.c
> @@ -3425,7 +3425,6 @@ isdn_tty_parse_at(modem_info *info)
>  			p++;
>  			isdn_tty_cmd_ATA(info);
>  			return;
> -			break;
>  		case 'D':
>  			/* D - Dial */
>  			if (info->msr & UART_MSR_DCD)
>=20


--=20
Chen Gang

Asianux Corporation
