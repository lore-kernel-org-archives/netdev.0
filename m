From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [net-next RFC 1/1] net sched actions: introduce timestamp for
 first time used
Date: Sun, 22 May 2016 12:32:33 -0400
Message-ID: <5741DF21.2020008@mojatatu.com>
References: <1463528337-4986-1-git-send-email-jhs@emojatatu.com>
 <CAM_iQpWXgncANS5MrBzrZiEVSbGzNptrAjisg_K2NTA-PsAMKg@mail.gmail.com>
 <573DA960.8070102@mojatatu.com> <573DAE70.4000504@mojatatu.com>
 <CAM_iQpW7LQ40XX5G+creyHjQbgdRcKCCJ1f5CbWHjdJdxJPPRA@mail.gmail.com>
 <CAM_iQpVP3MPAEBVn0buzkAaLzuYpba0Z5Va-V0CN_+G77eJhQQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Felix Fietkau <nbd@nbd.name>, baronchon@n7mm.org,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f177.google.com ([209.85.223.177]:33955 "EHLO
	mail-io0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752389AbcEVQcg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 May 2016 12:32:36 -0400
Received: by mail-io0-f177.google.com with SMTP id 190so179149904iow.1
        for <netdev@vger.kernel.org>; Sun, 22 May 2016 09:32:36 -0700 (PDT)
In-Reply-To: <CAM_iQpVP3MPAEBVn0buzkAaLzuYpba0Z5Va-V0CN_+G77eJhQQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-05-20 01:16 AM, Cong Wang wrote:

> One nit: It is better if you can swap 'stm' with 'dtm',
> it looks odd to put destination on the right side.
>

Will make the change for when net-next opens up.

cheers,
jamal
