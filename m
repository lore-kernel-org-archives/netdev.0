From: Ani Sinha <ani@arista.com>
Subject: Re: route/max_size sysctl in ipv4
Date: Tue, 6 Jan 2015 12:05:28 -0800
Message-ID: <CAOxq_8NxZA9Y-+y4VJEvRwO4nJFD+C+CCS0a+z9QkBeGzC9LYQ@mail.gmail.com>
References: <CAOxq_8NdxBScZ182bXs5KmTZLKRMeF3AVt+DJNFUff42gaZG4w@mail.gmail.com>
 <20150105.193614.1827024424476781168.davem@davemloft.net> <CAOxq_8OtQ0WD-PKBd4kX0JwZiaStqJ-cQiQRhWnTAK9Q0JquxA@mail.gmail.com>
 <20150105.195128.794605376092864881.davem@davemloft.net> <CAOxq_8OysjN8OrvhM13t3YUuyh5O=KM_mptR=NHieq146mqZ8g@mail.gmail.com>
 <54ABD80F.7070602@draigBrady.com> <CAOxq_8O-YME=m9NnCQ7hPWjr6jWqcqUkgeqM=ZY6VW+icNsO2g@mail.gmail.com>
 <1420567742.5947.1.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: =?UTF-8?Q?P=C3=A1draig_Brady?= <P@draigbrady.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:61200 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755903AbbAFUFt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 15:05:49 -0500
Received: by mail-ie0-f174.google.com with SMTP id at20so4757674iec.5
        for <netdev@vger.kernel.org>; Tue, 06 Jan 2015 12:05:49 -0800 (PST)
In-Reply-To: <1420567742.5947.1.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 6, 2015 at 10:09 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2015-01-06 at 09:11 -0800, Ani Sinha wrote:
>
>> Why can't se simply change the documentation to reflect the fact that
>> this sysctl is no longer in operation?
>
> It is still in operation for IPv6
>
> Looks like you propose to update the documentation.
>
> This is great !
>
> Why don't you send an official patch ?

Just did.
