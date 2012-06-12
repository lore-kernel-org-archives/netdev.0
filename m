From: Jean-Michel Hautbois <jhautbois@gmail.com>
Subject: Re: Difficulties to get 1Gbps on be2net ethernet card
Date: Tue, 12 Jun 2012 11:10:46 +0200
Message-ID: <CAL8zT=hJvBuRj0j4Fh7MOdvTUyYH7z+0jqkiK5OkeNc5-D-nJQ@mail.gmail.com>
References: <CAL8zT=hHAc5-wGMKgumV=K9jG6tDxzej9Dffe9UYQ24gdWQRtw@mail.gmail.com>
 <CAL8zT=jKhRjVCdYRCerMzimxPAhP5Gi+JBBfuKjG-rfg-LMoVw@mail.gmail.com>
 <1338360536.2760.85.camel@edumazet-glaptop> <CAL8zT=h2hoTWDMpTe8P-xfm-USXD6spx8fFVmm1UXyOfuuqhZw@mail.gmail.com>
 <1338361587.2760.94.camel@edumazet-glaptop> <CAL8zT=jHWhDdv-DyXL8XnL8qRc7o-jZfA7ADU-qt54hB5aLyCw@mail.gmail.com>
 <CAL8zT=gJT1Frn_44SU0CrpZjPxwC_VuHFE4k9jvOGNmFomzhHA@mail.gmail.com>
 <3367B80B08154D42A3B2BC708B5D41F647C678B73F@EXMAIL.ad.emulex.com>
 <CAL8zT=iP+5o11am67ZBVOd=QrOfcjFWDydiuM9RrrAKe_k7LZw@mail.gmail.com>
 <CAL8zT=ggT7Y2on6qmsp3u9CLOCwd6nOr3VjQfEsGZzA+O6us0A@mail.gmail.com>
 <1338980484.2760.4219.camel@edumazet-glaptop> <CAL8zT=hHDPnvRFcQ0w+D=AP+QK6ic4X=tva6Yw_XGwuTbAYjhQ@mail.gmail.com>
 <CAL8zT=jGHo82mo-s8Tfs9LWzfu2GkrS4eZJoeOpHhpXHMr6csg@mail.gmail.com>
 <CAL8zT=jY9YfdkBjk5VhwaSbzghCVUMXZZh+QAgc15LBBztczog@mail.gmail.com>
 <CAL8zT=g67JLZZjLF81+wxe9pmuPZ4EdpY1fHJMQNgcy9R6oBzg@mail.gmail.com>
 <1339072289.3494.3.camel@edumazet-glaptop> <CAL8zT=i2EkZLz3J5ib1tLnOuXt=Buf0sCwr7UbQWRE3B4oB+JQ@mail.gmail.com>
 <1339135709.6001.22.camel@edumazet-glaptop> <CAL8zT=jPUEF62-V_0n9o3=n2Mo6y4M_kGgK+OwdXg0aLDazDgQ@mail.gmail.com>
 <1339143759.6001.53.camel@edumazet-glaptop> <CAL8zT=i6zruaa0-bc-MG4FyhdM8RDtARd2E_o0+G-=p7RsJdGw@mail.gmail.com>
 <CAL8zT=gNtcdyyVcPt5hB6jyF1btzQArEuZgVKWkb0Wd=a4LcVA@mail.gmail.com>
 <1339491345.22704.22.camel@edumazet-glaptop> <CAL8zT=hKmnAG7kZE18noFNEksibvJpR_6Q9z59nGLhqbs5oxuw@mail.gmail.com>
 <1339491979.22704.23.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Sathya.Perla@emulex.com, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:52987 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751448Ab2FLJLJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jun 2012 05:11:09 -0400
Received: by weyu7 with SMTP id u7so2681710wey.19
        for <netdev@vger.kernel.org>; Tue, 12 Jun 2012 02:11:08 -0700 (PDT)
In-Reply-To: <1339491979.22704.23.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/6/12 Eric Dumazet <eric.dumazet@gmail.com>:
> On Tue, 2012-06-12 at 11:01 +0200, Jean-Michel Hautbois wrote:
>
>> Can I do that using netperf ?
>
>
> Sure, you could use netperf -t UDP_RR
>
>

It sends, but no change on TX...
