From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipvlan: fix up broadcast MAC filtering for ARP and DHCP
Date: Thu, 09 Apr 2015 09:01:00 -0700
Message-ID: <1428595260.25985.259.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1427409698.18540.11.camel@redhat.com>
	 <CAF2d9jjF20puZvoAD502rAzYAaraRtpZZRK-=vcZGu-Uv4wZMA@mail.gmail.com>
	 <1427749308.1913.28.camel@redhat.com>
	 <CAF2d9jipTV4f4NOgGRY-kGOyRBe5HAH6T-mj4G9FYnc7oyc+NA@mail.gmail.com>
	 <1427771158.1913.35.camel@redhat.com> <1427775770.30696.3.camel@redhat.com>
	 <CAF2d9jikrJU0k3sS=awZQN+SD46qnN4r0bubjXZiY7K9vQieEQ@mail.gmail.com>
	 <1427921700.6874.8.camel@redhat.com>
	 <CAF2d9jgqJBfWVnX1mye5xMfYznA_NFte3dEEKG5CyogXTM73Rw@mail.gmail.com>
	 <1427985636.5282.9.camel@redhat.com>
	 <CAF2d9jjBtSptfmFY2BDF7ULNxAz=WtUVpNz0iExyd-h+v+4GSQ@mail.gmail.com>
	 <1428340638.16890.15.camel@redhat.com>
	 <CAF2d9jgx6R5w_PoVzkstVgr0tATxTQv9S81QC9_YiX32vpRQVA@mail.gmail.com>
	 <1428435900.6449.25.camel@redhat.com> <1428594679.15316.0.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Mahesh Bandewar <maheshb@google.com>,
	linux-netdev <netdev@vger.kernel.org>, jbenc@redhat.com
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f171.google.com ([209.85.223.171]:35970 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756024AbbDIQBD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2015 12:01:03 -0400
Received: by iebrs15 with SMTP id rs15so104575271ieb.3
        for <netdev@vger.kernel.org>; Thu, 09 Apr 2015 09:01:02 -0700 (PDT)
In-Reply-To: <1428594679.15316.0.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-04-09 at 10:51 -0500, Dan Williams wrote:

> Any thoughts on this Mahesh?  Is this non-DHCP approach more to your
> liking?  If so I'll generate an actual patch and do some testing.

Pleas guys trim messages when replying. Otherwise people are bored and
do not even try to read them anymore.

Thanks.
