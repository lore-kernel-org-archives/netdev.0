From: Ben Greear <greearb@candelatech.com>
Subject: Re: Jitter and latency benchmarks with netlink / nl80211
Date: Wed, 10 Apr 2013 10:59:16 -0700
Message-ID: <5165A874.50804@candelatech.com>
References: <CAB=NE6XH8wGbFhmB54Y0BUB2N-PbzUBvN+arH5F_BAkEa=DjUw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-wireless <linux-wireless@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAB=NE6XH8wGbFhmB54Y0BUB2N-PbzUBvN+arH5F_BAkEa=DjUw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/10/2013 10:55 AM, Luis R. Rodriguez wrote:
> Curious if anyone has worked on latency and jitter benchmarks in using
> netlink, specifically with nl80211. Has anyone benchmarked this? Ben,
> have you? If not for nl80211 perhaps this has been done before for
> other netlink families?

You mean timing related to netlink configuration/report requests?

We have lots of ways to measure wifi packet throughput latencies
and jitter (to/from userspace and/or to/from pktgen), but it doesn't use
netlink....

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
