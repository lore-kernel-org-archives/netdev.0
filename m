From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [RFC PATCH kernel] Revert "net/mlx4_core: Add port attribute when
 tracking counters"
Date: Sun, 20 Sep 2015 16:51:07 +0300
Message-ID: <CAJ3xEMgRq60Yfv2R13yCwH1O15JMwy00zzJSTNqG+SxSpvo_4w@mail.gmail.com>
References: <1440770776-27951-1-git-send-email-aik@ozlabs.ru>
	<CAJ3xEMjbTFSKxURSuqFsjQNS6gJfdvgwo4NfYPrv2PrkgCt5YQ@mail.gmail.com>
	<55E3BE76.60801@ozlabs.ru>
	<CAKHjkjkLK2TJiKTxZ17jb0YH=oT-mBdKoYNb9aRQJm_vme_KkA@mail.gmail.com>
	<55E911A7.6090801@ozlabs.ru>
	<55F7F5C7.2060509@ozlabs.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: eran ben elisha <eranlinuxmellanox@gmail.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Matan Barak <matanb@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Yishai Hadas <yishaih@mellanox.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Richard Yang <weiyang@linux.vnet.ibm.com>,
	Gavin Shan <gwshan@linux.vnet.ibm.com>,
	Michael Ellerman <mpe@ellerman.id.au>,
	"talal@mellanox.com" <talal@mellanox.com>
To: Alexey Kardashevskiy <aik@ozlabs.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f46.google.com ([209.85.218.46]:33618 "EHLO
	mail-oi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755293AbbITNvI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Sep 2015 09:51:08 -0400
Received: by oixx17 with SMTP id x17so47116360oix.0
        for <netdev@vger.kernel.org>; Sun, 20 Sep 2015 06:51:08 -0700 (PDT)
In-Reply-To: <55F7F5C7.2060509@ozlabs.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 15, 2015 at 1:41 PM, Alexey Kardashevskiy <aik@ozlabs.ru> wrote:
> Any luck with that?

I am checking with the team if they can set a PPC node to try and
reproduce the crash, on x86 they don't see it.

Or.
