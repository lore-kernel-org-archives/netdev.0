From: Ilya Dryomov <idryomov@gmail.com>
Subject: Re: [PATCH] crush:Make the function crush_ln static
Date: Tue, 16 Jun 2015 20:15:31 +0300
Message-ID: <CAOi1vP9DayWYXw+KSFghjVvaK2pMT6MK4cvY96=D=tApdC08uw@mail.gmail.com>
References: <1433803863-9241-1-git-send-email-xerofoify@gmail.com>
	<CAOi1vP_G6eVwRW4coey4-gUEx3Y2k-pnDfJxMk6Va+C0aTLG-w@mail.gmail.com>
	<CAOi1vP8xL=ZdEH5fcGaMOkKbs5Hdjg9BLe6FxdRGVezdiighyQ@mail.gmail.com>
	<55804C64.3070702@gmail.com>
	<CAOi1vP84CnY+-0RvR=LJ3v-w_ZYBEuW4=AJ8xZUhKEjsLe0WdQ@mail.gmail.com>
	<55805563.6000101@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Yan, Zheng" <zyan@redhat.com>, Sage Weil <sage@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Ceph Development <ceph-devel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: nick <xerofoify@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55805563.6000101@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 16, 2015 at 7:57 PM, nick <xerofoify@gmail.com> wrote:
>
>
> On 2015-06-16 12:47 PM, Ilya Dryomov wrote:
>> On Tue, Jun 16, 2015 at 7:18 PM, nick <xerofoify@gmail.com> wrote:
>>> Ilya,
>>> That's fine I do have a unrelated question through. I have over 90 patches lying around in terms of cleanups/
>>> fixes and need help getting them merged. Should I just resend them or wait until the end of this merge window.
>>
>> Are all of those ceph patches?
>>
>> Thanks,
>>
>>                 Ilya
>>
> No there all over networking stack including drivers.

I'd suggest reaching out to the respective maintainers, especially if
those ~90 patches can be broken into a few chunks that a small number
of people can deal with.

If that doesn't get you anywhere, try resending the whole batch to
trivial@kernel.org.  Jiri may be able to merge it through his trivial
tree.

Thanks,

                Ilya
