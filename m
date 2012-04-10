From: Ryan Ware <ware@linux.intel.com>
Subject: Re: [PATCH v17 15/15] Documentation: prctl/seccomp_filter
Date: Tue, 10 Apr 2012 10:49:41 -0700
Message-ID: <CBA9C094.3CC91%ware@linux.intel.com>
References: <CABqD9hYQPDmNadkPw9O6fRXHpWDxh=MVPf7VB_3fz_X72dNz4w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>,
	<linux-security-module@vger.kernel.org>,
	<linux-arch@vger.kernel.org>, <linux-doc@vger.kernel.org>,
	<kernel-hardening@lists.openwall.com>, <netdev@vger.kernel.org>,
	<x86@kernel.org>, <arnd@arndb.de>, <davem@davemloft.net>,
	<hpa@zytor.com>, <mingo@redhat.com>, <oleg@redhat.com>,
	<peterz@infradead.org>, <rdunlap@xenotime.net>,
	<mcgrathr@chromium.org>, <tglx@linutronix.de>, <luto@mit.edu>,
	<eparis@redhat.com>, <serge.hallyn@canonical.com>,
	<djm@mindrot.org>, <scarybeasts@gmail.com>, <indan@nul.nu>,
	<pmoore@redhat.com>, <corbet@lwn.net>, <eric.dumazet@gmail.com>,
	<coreyb@linux.vnet.ibm.com>, <keescook@chromium.org>,
	<jmorris@namei.org>
To: Will Drewry <wad@chromium.org>,
	Markus Gutschke <markus@chromium.org>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <CABqD9hYQPDmNadkPw9O6fRXHpWDxh=MVPf7VB_3fz_X72dNz4w@mail.gmail.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 4/9/12 3:47 PM, "Will Drewry" <wad@chromium.org> wrote:

>On Mon, Apr 9, 2012 at 3:58 PM, Ryan Ware <ware@linux.intel.com> wrote:
>>
>> On 4/9/12 1:47 PM, "Markus Gutschke" <markus@chromium.org> wrote:
>>
>>>No matter what you do, please leave the samples accessible somewhere.
>>>They proved incredibly useful in figuring out how the API works. I am
>>>sure, other developers are going to appreciate them as well.
>>>
>>>Alternatively, if you don't want to include the samples with the
>>>kernel sources, figure out how you can include a sample in the
>>>official manual page for prctl().
>>>
>>
>> I second this!  They are extremely useful.
>>
>> Ryan
>
>In that case, would it make sense to put up a separate tools/testing
>patch and leave samples where they lie? (I'd _love_ to keep this patch
>series from acquiring another 1000 lines, but either way works :)
>
>My current tester and harness lives here:
>  https://github.com/redpig/seccomp/blob/master/tests/
>and the licensing can be sorted out prior to a patch mail.

I have absolutely no problems with that solution.  Availability is the
important thing.

Ryan


