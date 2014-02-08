From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [RFC] net: qmi_wwan: add ZTE MF667
Date: Sat, 08 Feb 2014 22:15:53 +0100
Message-ID: <87wqh5gvau.fsf@nemi.mork.no>
References: <1391893262-25092-1-git-send-email-raymond.wanyoike@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Raymond Wanyoike <raymond.wanyoike@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:41331 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751680AbaBHVP6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Feb 2014 16:15:58 -0500
In-Reply-To: <1391893262-25092-1-git-send-email-raymond.wanyoike@gmail.com>
	(Raymond Wanyoike's message of "Sun, 9 Feb 2014 00:01:02 +0300")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Raymond Wanyoike <raymond.wanyoike@gmail.com> writes:

> The driver description files give these descriptions to the vendor sp=
ecific
> ports on this modem:
>
>  VID_19D2&PID_1270&MI_00: "ZTE MF667 Diagnostics Port"
>  VID_19D2&PID_1270&MI_01: "ZTE MF667 AT Port"
>  VID_19D2&PID_1270&MI_02: "ZTE MF667 ATExt2 Port"
>  VID_19D2&PID_1270&MI_03: "ZTE MF667 ATExt Port"
>  VID_19D2&PID_1270&MI_04: "ZTE MF667 USB Modem"
>  VID_19D2&PID_1270&MI_05: "ZTE MF667 Network Adapter"
>
> Signed-off-by: Raymond Wanyoike <raymond.wanyoike@gmail.com>

Looks perfect to me.  Thanks.

Acked-by: Bj=C3=B8rn Mork <bjorn@mork.no>
