From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH v3] Add support for GPIOs for SMSC LAN95xx chips.
Date: Fri, 10 Oct 2014 14:02:15 +0200
Message-ID: <87fvewxhdk.fsf@nemi.mork.no>
References: <CAN_we7MbMywYzysn_Q_iRAOZZuE+KU_jDJxMW-Qz0KK0RHwSRQ@mail.gmail.com>
	<1412806498-22556-1-git-send-email-boger@contactless.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Daniele Forsi <dforsi@gmail.com>,
	Steve Glendinning <steve.glendinning@shawell.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org
To: Evgeny Boger <boger@contactless.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:43975 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751115AbaJJMCh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2014 08:02:37 -0400
In-Reply-To: <1412806498-22556-1-git-send-email-boger@contactless.ru> (Evgeny
	Boger's message of "Thu, 9 Oct 2014 02:14:58 +0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Evgeny Boger <boger@contactless.ru> writes:

> For LAN951x:
> GPIOs with offsets 0-7 are named "GPIO3" - "GPIO7",

The number of offsets does not match the number of names.



Bj=C3=B8rn
