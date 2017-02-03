From: Jon Mason <jon.mason@broadcom.com>
Subject: Re: [PATCH 2/3] net: ethernet: bgmac: unify code of the same family
Date: Fri, 3 Feb 2017 17:35:50 -0500
Message-ID: <CAC3K-4rHRuSaDf_ks5kZB0cQiW-suXy=M+uE0ORRPV2LT2AqKQ@mail.gmail.com>
References: <1486157970-6315-1-git-send-email-jon.mason@broadcom.com>
 <1486157970-6315-3-git-send-email-jon.mason@broadcom.com> <cdd5a5472af15d6da11e80306424d8b9@milecki.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: David Miller <davem@davemloft.net>,
        BCM Kernel Feedback <bcm-kernel-feedback-list@broadcom.com>,
        Network Development <netdev@vger.kernel.org>,
        open list <linux-kernel@vger.kernel.org>
To: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <rafal@milecki.pl>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cdd5a5472af15d6da11e80306424d8b9@milecki.pl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 3, 2017 at 4:48 PM, Rafa=C5=82 Mi=C5=82ecki <rafal@milecki.pl> =
wrote:
> On 2017-02-03 22:39, Jon Mason wrote:
>>
>> BCM471X and BCM535X are of the same family (from what I can derive from
>> internal documents).  Group them into the case statement together, which
>> results in more code reuse.
>>
>> Also, use existing helper variables to make the code a little more
>> readable too.
>>
>> Signed-off-by: Jon Mason <jon.mason@broadcom.com>
>
>
> I'd like to review it / test it on few devices. Please give me weekend fo=
r
> that.

Yes, please test this as much as you can.  The code move was pretty
innocuous, and those are always the times when it comes back to bite
me.

Thanks,
Jon
