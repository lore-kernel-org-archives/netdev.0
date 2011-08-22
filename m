From: Daniel Baluta <daniel.baluta@gmail.com>
Subject: Re: Miscalculated TCP ACK ?
Date: Mon, 22 Aug 2011 20:19:02 +0300
Message-ID: <CAEnQRZAB=tKwr0wX2OrpG8iq5VaJPmssHEfC3U62bz1XL_2FHw@mail.gmail.com>
References: <CAPbw_hwQSXtmFSxK49jDDgF2LuG8=cu5t=ZjQ_aO7=M9fm9xeA@mail.gmail.com>
	<1314031128.2307.110.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Gabriel Beddingfield <gabrbedd@gmail.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:61734 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751294Ab1HVRTE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2011 13:19:04 -0400
Received: by qwk3 with SMTP id 3so3101200qwk.19
        for <netdev@vger.kernel.org>; Mon, 22 Aug 2011 10:19:03 -0700 (PDT)
In-Reply-To: <1314031128.2307.110.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> It appears to me that the ACK is off-by-one (should have been 27676)=
=2E
>> The server replies again with retransmissions. =A0This is with sever=
al
>> kernel versions on local machines, ranging from 2.6.31 to 2.6.38.

> Not a bug if frame carried a FIN

Well then, why do retransmissions occur?
Gabriel could you post the full capture file?

thanks,
Daniel.
