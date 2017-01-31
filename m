From: Pavel Belous <pavel.s.belous@gmail.com>
Subject: Re: [PATCH v2] net: aquantia: atlantic: use new api
 ethtool_{get|set}_link_ksettings
Date: Tue, 31 Jan 2017 17:50:50 +0300
Message-ID: <2d5f7c8e-e7fb-3dd4-4f85-08f01c5f40e0@gmail.com>
References: <1485813882-9887-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexander.Loktionov@aquantia.com, vomlehn@texas.net,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: tremyfr@gmail.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f66.google.com ([209.85.215.66]:33212 "EHLO
        mail-lf0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750819AbdAaOxU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 09:53:20 -0500
In-Reply-To: <1485813882-9887-1-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>The ethtool api {get|set}_settings is deprecated.
>We move this driver to new api {get|set}_link_ksettings.
>
>As I don't have the hardware, I'd be very pleased if
>someone may test this patch.
>  >Signed-off-by: Philippe Reynes <tremyfr@gmail.com> Tested-by: Pavel 
Belous <pavel.s.belous@gmail.com>
