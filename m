From: David Miller <davem@davemloft.net>
Subject: Re: [PULL] topic/e1000e-fix
Date: Wed, 31 May 2017 11:08:33 -0400 (EDT)
Message-ID: <20170531.110833.1362264472730468352.davem@davemloft.net>
References: <CAPM=9twH-CXm+xj2Os87Ra7nOBQ+WNXYGF83wFqpQ3s=MNx_mQ@mail.gmail.com>
        <CAKMK7uF-b1U7qipgEoYnAjDtrNdvKYT4KkoV2=krikkdGERkCw@mail.gmail.com>
        <CAKMK7uGbi2Bwfno9XogKZ-LUOyMepbtRyGuGrNYWwj6Cts+uag@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: airlied@gmail.com, intel-gfx@lists.freedesktop.org,
        dri-devel@lists.freedesktop.org, jani.nikula@linux.intel.com,
        jeffrey.t.kirsher@intel.com, intel-wired-lan@lists.osuosl.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: daniel.vetter@ffwll.ch
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAKMK7uGbi2Bwfno9XogKZ-LUOyMepbtRyGuGrNYWwj6Cts+uag@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Daniel Vetter <daniel.vetter@ffwll.ch>
Date: Wed, 31 May 2017 08:10:45 +0200

> On Wed, May 31, 2017 at 7:54 AM, Daniel Vetter <daniel.vetter@ffwll.ch> wrote:
>> On Wed, May 31, 2017 at 1:06 AM, Dave Airlie <airlied@gmail.com> wrote:
>>> On 31 May 2017 at 08:10, David Miller <davem@davemloft.net> wrote:
>>>> From: Daniel Vetter <daniel.vetter@ffwll.ch>
>>>> Date: Tue, 30 May 2017 22:15:42 +0200
>>>>
>>>>> If the e1000e maintainer wants to coalesce or not return statements
>>>>> this simple way, that's imo on him to change the color as needed.
>>>>
>>>> That's not how things work.
>>>>
>>>> If the maintainer wants you to style things a certain way, either you
>>>> do it that way or your patch isn't accepted.
>>
>> Consider this pull a regression report, pls handle it.
> 
> And I guess I pile of more cc, to make this regression report
> complete. I mean you got the backtrace, bisect and a proposed fix, and
> the almost-whitespace change demanded is something gcc does in its
> sleep. I'd understand a request to retest if it would be a real
> functional change, but in this situation I have no idea why this
> regression just can't be fixed already.

And we can't understand why respinning with the requested change is
less work than making several postings such as this one.
