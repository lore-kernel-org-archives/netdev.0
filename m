From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next] vlan: take link netns into account in vlan_newlink()
Date: Mon, 26 Jan 2015 12:02:41 +0100
Message-ID: <54C61ED1.5040501@6wind.com>
References: <1422265455-4331-1-git-send-email-nicolas.dichtel@6wind.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f47.google.com ([74.125.82.47]:49410 "EHLO
	mail-wg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752793AbbAZLCo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2015 06:02:44 -0500
Received: by mail-wg0-f47.google.com with SMTP id n12so8306647wgh.6
        for <netdev@vger.kernel.org>; Mon, 26 Jan 2015 03:02:43 -0800 (PST)
In-Reply-To: <1422265455-4331-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 26/01/2015 10:44, Nicolas Dichtel a =C3=A9crit :
> When IFLA_LINK_NETNSID is set, the ifindex from IFLA_LINK comes from =
another
> netns.
>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Please, discard this patch. It's not the right fix.
I will send an update later.
