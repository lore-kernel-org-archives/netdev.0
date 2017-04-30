From: Don Bowman <db@donbowman.ca>
Subject: Re: ipsec doesn't route TCP with 4.11 kernel
Date: Sat, 29 Apr 2017 20:39:34 -0400
Message-ID: <CADJev7_Tc0aRsPs0Q7Wijd-YBM39ZshitJpSo2yEqPVwag2X_Q@mail.gmail.com>
References: <CADJev78Cs0VBdagtfU-71pv3HHC5Vq41UXQee856aVbUqEqAYg@mail.gmail.com>
 <CAM_iQpWT5tF5+LpoTP98JNJ=440jEkxHFkn8=jtAsZgondN49A@mail.gmail.com>
 <20170427084238.GX2649@secunet.com> <CADJev7_=YEHmijGweqZvdATMQVuzwywEbBKweYvPurJfTEQRjQ@mail.gmail.com>
 <20170428071337.GG2649@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f47.google.com ([209.85.214.47]:36837 "EHLO
        mail-it0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1427085AbdD3Ajf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 29 Apr 2017 20:39:35 -0400
Received: by mail-it0-f47.google.com with SMTP id r185so12994563itd.1
        for <netdev@vger.kernel.org>; Sat, 29 Apr 2017 17:39:35 -0700 (PDT)
In-Reply-To: <20170428071337.GG2649@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 28 April 2017 at 03:13, Steffen Klassert
<steffen.klassert@secunet.com> wrote:
> On Thu, Apr 27, 2017 at 06:13:38PM -0400, Don Bowman wrote:
>> On 27 April 2017 at 04:42, Steffen Klassert <steffen.klassert@secunet.com>
>> wrote:
>> > On Wed, Apr 26, 2017 at 10:01:34PM -0700, Cong Wang wrote:
>> >> (Cc'ing netdev and IPSec maintainers)
>> >>
>> >> On Tue, Apr 25, 2017 at 6:08 PM, Don Bowman <db@donbowman.ca> wrote:
>>

<snip>

confirmed, with this patch in place that the tcp functions properly.
