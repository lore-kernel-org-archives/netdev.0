From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: Re: Jitter and latency benchmarks with netlink / nl80211
Date: Wed, 10 Apr 2013 11:05:40 -0700
Message-ID: <CAB=NE6U_0E+y8jc_0O3+9pmUyLXX9CuSMYMMWk__4Q8-+-AHTg@mail.gmail.com>
References: <CAB=NE6XH8wGbFhmB54Y0BUB2N-PbzUBvN+arH5F_BAkEa=DjUw@mail.gmail.com>
 <5165A874.50804@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-wireless <linux-wireless@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5165A874.50804@candelatech.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 10, 2013 at 10:59 AM, Ben Greear <greearb@candelatech.com> wrote:
> On 04/10/2013 10:55 AM, Luis R. Rodriguez wrote:
>>
>> Curious if anyone has worked on latency and jitter benchmarks in using
>> netlink, specifically with nl80211. Has anyone benchmarked this? Ben,
>> have you? If not for nl80211 perhaps this has been done before for
>> other netlink families?
>
>
> You mean timing related to netlink configuration/report requests?

Yes.

> We have lots of ways to measure wifi packet throughput latencies
> and jitter (to/from userspace and/or to/from pktgen), but it doesn't use
> netlink....

Not looking for latency / jitter for 802.11, but for the core nl80211 messages.

  Luis
