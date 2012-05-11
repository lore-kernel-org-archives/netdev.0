From: Helmut Stengele <admin@coldplug.net>
Subject: Re: [PATCH] mwl8k: Add 0x2a02 PCI device-id (Marvell 88W8361)
Date: Fri, 11 May 2012 10:01:46 +0200
Message-ID: <4FACC76A.6010801@coldplug.net>
References: <20120427094637.GV3157@wantstofly.org> <CA+icZUXNZ=exTnR=OgD_9bpt_0s-KnR+v-K6u+XzQr4HBoTQHQ@mail.gmail.com> <20120427095842.GW3157@wantstofly.org> <CA+icZUWuynSaPE4pdxzoP783pw7r=5x27ewXN_pkR5VS=0kKUg@mail.gmail.com> <20120427101732.GX3157@wantstofly.org> <CA+icZUUnJPeDmL9xXfvj62an40bXwwaOnrJmxmLN_cBt9PyCZA@mail.gmail.com> <CA+icZUV76wSBj88EpzmWbO=u2dP23yi5P98nN2KZehBUni9mEg@mail.gmail.com> <20120427185809.GZ3157@wantstofly.org> <CA+icZUWQmCRdjucb4+Nf24_zbJ4fzzp7zjqhKjXE6U01rppDfA@mail.gmail.com> <CA+icZUXSaEMA=KbQP9UQcU6ZMBh8QD2sv-O=6r_Ly8is==gvSA@mail.gmail.com> <20120501125102.GN3157@wantstofly.org> <1336406944.2385.24.camel@dcbw.foobar.com> <1336408965.2385.25.camel@dcbw.foobar.com> <CAJ-Vmok92fR_JfqD2BrnP7A0c8Vs5K7T-77nzt7B+sPPgk6KNw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Dan Williams <dcbw@redhat.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	sedat.dilek@gmail.com, "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Jim Cromie <jim.cromie@gmail.com>
To: Adrian Chadd <adrian@freebsd.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from coldplug.net ([109.75.184.172]:33930 "EHLO
	external.coldplug.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756989Ab2EKICZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2012 04:02:25 -0400
Received: from localhost (localhost [127.0.0.1])
	by external.coldplug.net (Postfix) with ESMTP id A0DD53A964
	for <netdev@vger.kernel.org>; Fri, 11 May 2012 10:03:26 +0200 (CEST)
Received: from external.coldplug.net ([127.0.0.1])
	by localhost (external.coldplug.net [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id O0Z6DYACJF7Z for <netdev@vger.kernel.org>;
	Fri, 11 May 2012 10:03:26 +0200 (CEST)
In-Reply-To: <CAJ-Vmok92fR_JfqD2BrnP7A0c8Vs5K7T-77nzt7B+sPPgk6KNw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/07/2012 08:26 PM, Adrian Chadd wrote:
> Hi,
>
> Let me see if the topdog firmware that FreeBSD ships with supports hostap mode.
>
> I'm having aggregation issues but I think that's driver side, not firmware side.
>
>
>
> Adrian
>
i didn't change anything since the manual addition
of the patch into 3.4-rc and it looks like only the reported
speed is worse, taking the card up with wpa_sup gives me
enought speed to transfer audiovisual content without
loss or stutter.
( card is on a mythfrontend using DVD-quality streams ).

may be comfortable to have certain commands working
or using the AP capabilities but at least the gerneric usage
is given.

Helmut
