From: Alexey Kardashevskiy <aik@ozlabs.ru>
Subject: Re: [RFC PATCH kernel] Revert "net/mlx4_core: Add port attribute when
 tracking counters"
Date: Tue, 22 Sep 2015 16:57:01 +1000
Message-ID: <5600FBBD.80705@ozlabs.ru>
References: <1440770776-27951-1-git-send-email-aik@ozlabs.ru>
 <CAJ3xEMjbTFSKxURSuqFsjQNS6gJfdvgwo4NfYPrv2PrkgCt5YQ@mail.gmail.com>
 <55E3BE76.60801@ozlabs.ru>
 <CAKHjkjkLK2TJiKTxZ17jb0YH=oT-mBdKoYNb9aRQJm_vme_KkA@mail.gmail.com>
 <55E911A7.6090801@ozlabs.ru> <55F7F5C7.2060509@ozlabs.ru>
 <CAJ3xEMgRq60Yfv2R13yCwH1O15JMwy00zzJSTNqG+SxSpvo_4w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r; format=flowed
Content-Transfer-Encoding: 7bit
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
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:33739 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756775AbbIVG5M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 02:57:12 -0400
Received: by pacex6 with SMTP id ex6so1061679pac.0
        for <netdev@vger.kernel.org>; Mon, 21 Sep 2015 23:57:11 -0700 (PDT)
In-Reply-To: <CAJ3xEMgRq60Yfv2R13yCwH1O15JMwy00zzJSTNqG+SxSpvo_4w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/20/2015 11:51 PM, Or Gerlitz wrote:
> On Tue, Sep 15, 2015 at 1:41 PM, Alexey Kardashevskiy <aik@ozlabs.ru> wrote:
>> Any luck with that?
>
> I am checking with the team if they can set a PPC node to try and
> reproduce the crash, on x86 they don't see it.

Somehow I cannot reproduce it anymore on v4.2 kernel which is quite 
disturbing. I'll get back as soon as I see this again...


-- 
Alexey
