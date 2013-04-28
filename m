From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: [PATCH v2] x86: make DR*_RESERVED unsigned long
Date: Sun, 28 Apr 2013 10:43:50 -0700
Message-ID: <517D5FD6.9070009@zytor.com>
References: <20130424170702.GA1867@redhat.com> <5178282D.9030902@zytor.com> <20130425144818.GA25921@redhat.com> <20130426163802.GA30351@redhat.com> <517AAED5.7040400@zytor.com> <20130426171526.GA30875@redhat.com> <20130427144537.GA24256@redhat.com> <20130428005814.GB10354@somewhere> <20130428172731.GA26169@redhat.com> <517D5D3A.8070505@zytor.com> <20130428173932.GA30773@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Frederic Weisbecker <fweisbec@gmail.com>,
	Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Cyrill Gorcunov <gorcunov@gmail.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Thomas Gleixner <tglx@linutronix.de>,
	David Miller <davem@davemloft.net>,
	"Theodore Ts'o" <tytso@mit.edu>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	the arch/x86 maintainers <x86@kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	"linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>
To: Oleg Nesterov <oleg@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130428173932.GA30773@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/28/2013 10:39 AM, Oleg Nesterov wrote:
> On 04/28, H. Peter Anvin wrote:
>>
>> On 04/28/2013 10:27 AM, Oleg Nesterov wrote:
>>
>> Looks good.  However, given the timing, I would think this is 3.11
>> material unless we have a manifest bug at this point.
> 
> Yes, yes, this is only cleanup.
> 

Thanks for tackling it.  I just wanted to make sure you didn't wonder
why I didn't want to push it for 3.10.

	-hpa
