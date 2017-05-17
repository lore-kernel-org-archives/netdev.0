From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] rt2x00: improve calling conventions for register accessors
Date: Wed, 17 May 2017 16:48:49 +0200
Message-ID: <CAK8P3a2Ni_zizij1tupmfJcg4mLHDFv5aVJvPHhJ5k4P8y=ECg@mail.gmail.com>
References: <20170515134711.2770374-1-arnd@arndb.de> <20170515142520.GA13996@redhat.com>
 <20170515.103951.2305484593464882104.davem@davemloft.net> <20170516115511.GA4230@redhat.com>
 <0ce21c48-1d2c-3035-3c6e-52c7debf86d5@gmail.com> <CAK8P3a18opkvCyoNmYhR6M7XXEq8f__hMZH1A6w8UFP7qbmQWw@mail.gmail.com>
 <0080a870-2d15-9b60-b7fb-8847d3c8aa8a@gmail.com> <CAKR_QVKYpcficnx5G5NdLKh7xa9S18udYQNXDQ=LmfG=Qeapbg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Jes Sorensen <jes.sorensen@gmail.com>,
        Stanislaw Gruszka <sgruszka@redhat.com>,
        David Miller <davem@davemloft.net>,
        Helmut Schaa <helmut.schaa@googlemail.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        Daniel Golle <daniel@makrotopia.org>,
        Mathias Kresin <dev@kresin.me>,
        Johannes Berg <johannes.berg@intel.com>,
        Serge Vasilugin <vasilugin@yandex.ru>,
        Roman Yeryomin <roman@advem.lv>,
        linux-wireless <linux-wireless@vger.kernel.org>,
        Networking <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Tom Psyborg <pozega.tomislav@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:32969 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753244AbdEQOs4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 17 May 2017 10:48:56 -0400
In-Reply-To: <CAKR_QVKYpcficnx5G5NdLKh7xa9S18udYQNXDQ=LmfG=Qeapbg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 17, 2017 at 2:17 PM, Tom Psyborg <pozega.tomislav@gmail.com> wrote:
>
>
> On 16 May 2017 at 16:31, Jes Sorensen <jes.sorensen@gmail.com> wrote:
>>
>>
>> True - if the automatic conversion works without automatic intervention, I
>> am less worried about it. Personally I would still focus on converting one
>> function at a time to reduce the impact of each patch.
>>
> give me a single patch with all changes to try

I've sent a series of 10 patches now that does it all one (or two in some cases)
function at a time. The combined patch is a little too large to send
on the mailing
list.

     Arnd
