From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH net V2 1/2] virtio-net: don't respond to cpu hotplug
	notifier if we're not ready
Date: Fri, 18 Oct 2013 16:47:14 +1030
Message-ID: <87iowvje6t.fsf@rustcorp.com.au>
References: <8738o0aj9u.fsf@rustcorp.com.au>
	<20131017050710.GA12141@redhat.com>
	<87d2n3s89s.fsf@rustcorp.com.au>
	<20131017.234816.1960399038382112445.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, gregkh@linuxfoundation.org
To: David Miller <davem@davemloft.net>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20131017.234816.1960399038382112445.davem@davemloft.net>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:
> From: Rusty Russell <rusty@rustcorp.com.au>
> Date: Fri, 18 Oct 2013 11:30:15 +1030
>
>> Asking people to express 'CC: stable' in words is error-prone; if Dave
>> wants to filter it, he's quite capable.
>
> Filtering it one time is one thing.
>
> Potentially acting on that filter 100 or so times a day...
>
> That's completely another.

I don't see the difference between reacting to:

> The patch were need for 3.10 and above.

And:

CC: stable@kernel.org # 3.10+

Except the latter is the standard form which everyone else uses.

Do you want awk script to turn the latter into the former?  Would that
really help?

Confused,
Rusty.
