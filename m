From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH 1/1] AX88179_178A: Add VID:DID for Lenovo OneLinkDock Gigabit LAN
Date: Wed, 26 Feb 2014 13:13:12 +0100
Message-ID: <87zjle6pif.fsf@nemi.mork.no>
References: <1393404871-2248-1-git-send-email-freddy@asix.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org
To: freddy@asix.com.tw
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1393404871-2248-1-git-send-email-freddy@asix.com.tw>
	(freddy@asix.com.tw's message of "Wed, 26 Feb 2014 16:54:31 +0800")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

freddy@asix.com.tw writes:

> From: Freddy Xin <freddy@asix.com.tw>
>
> Add VID:DID for Lenovo OneLinkDock Gigabit LAN

This is the same patch Keith Packard sent, but with a slighly different
description.  I take that as another proof that we should not attempt t=
o
describe devices in these drivers.  Describe the driver instead.




Bj=C3=B8rn
