From: Jochen Friedrich <jochen@scram.de>
Subject: Re: [PATCH 1/5] new pcmcia IDs for hostap - ASUS WL-110
Date: Sat, 13 May 2006 11:58:19 +0200
Message-ID: <4465ADBB.80409@scram.de>
References: <200605121521.32410.linux-arm@hrw.one.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jouni Malinen <jkmaline@cc.hut.fi>,
	Pavel Roskin <proski@gnu.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail0.scram.de ([195.226.127.110]:24839 "EHLO mail0.scram.de")
	by vger.kernel.org with ESMTP id S932188AbWEMJ6x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 May 2006 05:58:53 -0400
To: Marcin Juszkiewicz <linux-arm@hrw.one.pl>
In-Reply-To: <200605121521.32410.linux-arm@hrw.one.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Marcin,

> root@ipaq-pxa270:~# pccardctl ident
> Socket 0:
>   product info: "ASUS", "802_11B_CF_CARD_25", "Version 01.00", ""
>   manfid: 0x02aa, 0x0002
>   function: 6 (network)

Yet another card known to work OK with hostap_cs:

# pccardctl ident
Socket 0:
  no product info available
Socket 1:
  product info: "U.S. Robotics", "IEEE 802.11b PC-CARD", "Version 01.02", ""
  manfid: 0x0156, 0x0002
  function: 6 (network)

Thanks,
Jochen
