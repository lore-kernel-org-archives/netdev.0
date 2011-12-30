From: "Li, Zhen-Hua" <lizhenhua.dev@gmail.com>
Subject: Re: A pure virtual nic
Date: Fri, 30 Dec 2011 09:51:11 +0800
Message-ID: <CAEk7JKY6xtBm4DraqRMYEnmZZhsOZoZG-MSgrq+W4n2eCCz1Sg@mail.gmail.com>
References: <CAEk7JKbQgjiL90oGyWy6jkwY7eudUUqLP7GvdjfMcotTN8YhwQ@mail.gmail.com>
	<CAHXqBFKstJCQ4rif6S7mNuQUzFjJ1wfRKAksFePJyBoTw0YTfg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux NetDev <netdev@vger.kernel.org>
To: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:36269 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751545Ab1L3BvM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Dec 2011 20:51:12 -0500
Received: by iaeh11 with SMTP id h11so24504408iae.19
        for <netdev@vger.kernel.org>; Thu, 29 Dec 2011 17:51:12 -0800 (PST)
In-Reply-To: <CAHXqBFKstJCQ4rif6S7mNuQUzFjJ1wfRKAksFePJyBoTw0YTfg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I plan to add some protocols to it. For example, HTTP Proxy packet
analysis. So user-space programs can use an NIC in common way in a
proxy needed environment.



2011/12/29 Micha=C5=82 Miros=C5=82aw <mirqus@gmail.com>:
> 2011/12/29 Zhen-Hua Li <lizhenhua.dev@gmail.com>:
>> I have opened a project in SourceForge, it provides a pure virtual
>> ethernet adapter. =C2=A0If you are interested to join it, please mai=
l me.
>
> Is veth or tap (both in vanilla kernel) not enough for you? What are
> the differences?
>
> Best Regards,
> Micha=C5=82 Miros=C5=82aw
