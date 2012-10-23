From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [net-next:master 35/53] net/ipv6/route.c:400:13: sparse: invalid
 assignment: ^=
Date: Tue, 23 Oct 2012 10:58:10 +0200
Message-ID: <50865C22.1090503@6wind.com>
References: <508653b5.7Vy7DCd02KcUpUab%fengguang.wu@intel.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Fengguang Wu <fengguang.wu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:45607 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932238Ab2JWI6O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2012 04:58:14 -0400
Received: by mail-bk0-f46.google.com with SMTP id jk13so1417264bkc.19
        for <netdev@vger.kernel.org>; Tue, 23 Oct 2012 01:58:13 -0700 (PDT)
In-Reply-To: <508653b5.7Vy7DCd02KcUpUab%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 23/10/2012 10:22, Fengguang Wu a =E9crit :
> Hi Nicolas,
>
> FYI, there are new sparse warnings show up in
>
> tree:   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.=
git master
> head:   598e74f32c6dd4b3dd0ed382c889be07a7c6cbc0
> commit: 51ebd3181572af8d5076808dab2682d800f6da5d [35/53] ipv6: add su=
pport of equal cost multipath (ECMP)
Right, I will send a patch.


Thank you,
Nicolas
