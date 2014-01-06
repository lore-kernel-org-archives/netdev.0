From: hayeswang <hayeswang@realtek.com>
Subject: RE: [PATCH net-next v2 6/6] r8152: support RTL8153
Date: Mon, 6 Jan 2014 11:20:43 +0800
Message-ID: <AA7EB9EA13B74B14BBE08C4278F7948C@realtek.com.tw>
References: <1388632963-1341-1-git-send-email-hayeswang@realtek.com><1388633110-1435-1-git-send-email-hayeswang@realtek.com><877gai8nqu.fsf@nemi.mork.no><605671F106F540BA9665A195CACB78A0@realtek.com.tw> <8738l58pyd.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <oliver@neukum.org>, <netdev@vger.kernel.org>,
	'nic_swsd' <nic_swsd@realtek.com>,
	<linux-kernel@vger.kernel.org>, <linux-usb@vger.kernel.org>
To: =?iso-8859-1?Q?'Bj=F8rn_Mork'?= <bjorn@mork.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <8738l58pyd.fsf@nemi.mork.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 Bj=F8rn Mork [mailto:bjorn@mork.no]=20
[...]
> Sorry, but then this makes even less sense.  The active USB
> configuration is user selectable and you should make any of=20
> them work if
> possible.  Why can't the drivers figure out this at runtime?

Excuse me. I have no idea about how to switch the configuration at
the runtime ,and how to change the default configuration when a
USB device is plugged. When a user select one of the configurations,
he/she would wish to fix the configuration number after rebooting or
after the dangle is unplugged and plugged again. For these reasons,
this is the simple way which I could think. Maybe I choose the wrong
method because I don't know how to satisfy the requests. May you
provide me the relative information? Then, I could replace the current
method. Thanks.
=20
Best Regards,
Hayes
