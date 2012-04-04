From: Mike Sinkovsky <msink@permonline.ru>
Subject: Re: [PATCH v6 0/2] Ethernet drivers for WIZnet chips
Date: Wed, 04 Apr 2012 13:25:57 +0600
Message-ID: <4F7BF785.9060205@permonline.ru>
References: <1332752876-1650-1-git-send-email-msink@permonline.ru> <1333450726-24455-1-git-send-email-msink@permonline.ru> <1333453170.18626.65.camel@edumazet-glaptop> <4F7AE9D3.80204@permonline.ru> <1333456156.18626.93.camel@edumazet-glaptop> <4F7BE30B.9020603@permonline.ru> <1333520260.18626.383.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1333520260.18626.383.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

04.04.2012 12:17, Eric Dumazet =D0=BD=D0=B0=D0=BF=D0=B8=D1=81=D0=B0=D0=BB=
:
> On Wed, 2012-04-04 at 11:58 +0600, Mike Sinkovsky wrote:
>
>> About races - I can't see any, in this very simple procedure.
>> But maybe I missed something..
>
> Maybe post the code and we can help you.

Posted v7.

But - today I don't see tx_timeout(), even if flow control is enabled!
Weird still...

--=20
Mike
