From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: regression kernel 4.4: stops routing packets with a GRE-payload
Date: Wed, 20 Jan 2016 17:58:52 +0100
Message-ID: <569FBCCC.7070607@6wind.com>
References: <2738275.ziX0sZKPG0@stwm.de>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Wolfgang Walter <linux@stwm.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:38820 "EHLO
	mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934743AbcATQ6z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2016 11:58:55 -0500
Received: by mail-wm0-f41.google.com with SMTP id b14so39640217wmb.1
        for <netdev@vger.kernel.org>; Wed, 20 Jan 2016 08:58:55 -0800 (PST)
In-Reply-To: <2738275.ziX0sZKPG0@stwm.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 20/01/2016 15:00, Wolfgang Walter a =E9crit :
> Hello,
>
> we tried 4.4 on our routers. We found one problem: 4.4 stops routing =
GRE
> packets (ipv4 in GRE/ipv4) here. 4.4.15 works fine.
4.4.15 does not exist. Is it 4.1.15?
