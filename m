From: Santiago Garcia Mantinan <manty@debian.org>
Subject: Fwd: bridge-utils: wrong sysfs path odds
Date: Wed, 25 Nov 2015 23:44:28 +0100
Message-ID: <CAJk_L2G-j+2dpOA_U=fTeR=SL2Y8DJ=6DStaaDQ6rSAcAv4A+A@mail.gmail.com>
References: <5654FD93.1070706@nod.at>
	<5654FFCF.2080801@nod.at>
	<20151124163735.6f9ad756@xeon-e3>
	<56557D8B.8090908@nod.at>
	<CAJk_L2GSvNUGiexawakMHdm+v5ndv=qLXB9TD7xxn7z9c-ZMsg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ralf Baechle <ralf@linux-mips.org>
To: Richard Weinberger <richard@nod.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f42.google.com ([209.85.215.42]:34404 "EHLO
	mail-lf0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752048AbbKYWo3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2015 17:44:29 -0500
Received: by lffu14 with SMTP id u14so77806239lff.1
        for <netdev@vger.kernel.org>; Wed, 25 Nov 2015 14:44:28 -0800 (PST)
In-Reply-To: <CAJk_L2GSvNUGiexawakMHdm+v5ndv=qLXB9TD7xxn7z9c-ZMsg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(Message resent due to list rejection)

Hi!

> Ask Debian maintainer to send his patches, I don't go patch hunting.
>
>
> While looking what other distros do I came across this patch:
> https://pkgs.fedoraproject.org/cgit/bridge-utils.git/tree/bridge-utils-1.5-check-error-returns-from-write-to-sysfs.patch
>

Don't know about the fedora guys but at least I did send some patches
which include this /bridge addition, and Stephen did even ack it as
you can read on:
http://lists.linuxfoundation.org/pipermail/bridge/2011-May/007646.html

Regards.
-- 
Manty/BestiaTester -> http://manty.net
