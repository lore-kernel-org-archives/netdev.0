From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Subject: Re: [PATCH v2] socket.7: add description for SO_BUSY_POLL
Date: Wed, 10 Jul 2013 20:57:16 +0200
Message-ID: <CAKgNAkhk+K=t0fu12Q03wcp18JrNsudTpEYs4=XP8KF81918ZQ@mail.gmail.com>
References: <20130710141835.15799.61657.stgit@ladj378.jer.intel.com>
 <51DDA1DC.2020306@gmail.com> <20130710.115215.1793423861402826221.davem@davemloft.net>
Reply-To: mtk.manpages@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: eliezer.tamir@linux.intel.com,
	linux-man <linux-man@vger.kernel.org>,
	lkml <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>, eliezer@tamir.org.il
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130710.115215.1793423861402826221.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 10, 2013 at 8:52 PM, David Miller <davem@davemloft.net> wrote:
> From: Michael Kerrisk <mtk.manpages@gmail.com>
> Date: Wed, 10 Jul 2013 20:03:08 +0200
>
>> On 07/10/13 16:18, Eliezer Tamir wrote:
>>> Add description for the SO_BUSY_POLL socket option to the socket(7) manpage.
>>>
>>> v2
>>> fixed typos reported by Rasmus Villemoes
>>
>> Eliezer,
>>
>> What's the status of this feature. A quick grep seems to show
>> that the feature is not yet in mainline. What is the plan?
>
> It's in Linus's tree.

That doesn't appear to be the case. grepping current Linus Git for
SO_BUSY_POLL yields nada. What am I missing?
