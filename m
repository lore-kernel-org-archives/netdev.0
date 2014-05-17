From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: 3.14 tc oops
Date: Fri, 16 May 2014 17:24:17 -0700
Message-ID: <CAM_iQpWFpwNrece+wuV090D_C_K0VrPGYv-JNe23TDezJ9Y0-g@mail.gmail.com>
References: <1592838.91HrDxMk9i@comer>
	<CAM_iQpVgEtDqbK6-JoMn8-1D_cOsRTGPozvbmxbCBKi1+ss-rQ@mail.gmail.com>
	<CAM_iQpU+A+1FxFNkibvbkM=vkWVw7QmHJzE_AODVTgzUEjdeDg@mail.gmail.com>
	<3222104.QGqslXqjVx@comer>
	<CAM_iQpVVwE6+SgYKr5kiHhv0yE3-eRynxo5AkPSL5ZQ=aA5aJw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Daniel Borkmann <dborkman@redhat.com>
To: Kelly Anderson <kelly@xilka.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f179.google.com ([209.85.214.179]:59356 "EHLO
	mail-ob0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752475AbaEQAYR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2014 20:24:17 -0400
Received: by mail-ob0-f179.google.com with SMTP id vb8so3738350obc.38
        for <netdev@vger.kernel.org>; Fri, 16 May 2014 17:24:17 -0700 (PDT)
In-Reply-To: <CAM_iQpVVwE6+SgYKr5kiHhv0yE3-eRynxo5AkPSL5ZQ=aA5aJw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 16, 2014 at 5:18 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Mon, Apr 7, 2014 at 1:00 AM, Kelly Anderson <kelly@xilka.com> wrote:
>> Cong,
>>
>> The patch did not fix the problem.
>>
>> For your convenience, I've attached tc filter show for eth0 and eth1, as well
>> as a mangled version of my tcng input file.
>>
>
>
> Sorry that I totally forgot this thread....
>
> I just tested a new patch (attached), it works for me, please verify it.
>


Note I just ran ping test after setup filters with the script you sent to me.
Please double check if all filters still work as before.

Thanks.
