From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH repost] ptr_ring: fix race conditions when resizing
Date: Mon, 20 Feb 2017 11:24:42 -0500 (EST)
Message-ID: <20170220.112442.886413596934117545.davem@davemloft.net>
References: <1487171217-6641-1-git-send-email-mst@redhat.com>
        <20170219.005248.548256056859453600.davem@davemloft.net>
        <20170220070458-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, dvyukov@google.com,
        stable@vger.kernel.org, jasowang@redhat.com, netdev@vger.kernel.org
To: mst@redhat.com
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20170220070458-mutt-send-email-mst@kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Mon, 20 Feb 2017 07:05:35 +0200

> On Sun, Feb 19, 2017 at 12:52:48AM -0500, David Miller wrote:
>> From: "Michael S. Tsirkin" <mst@redhat.com>
>> Date: Sun, 19 Feb 2017 07:17:17 +0200
>> 
>> > Dave, could you merge this before 4.10? If not - I can try.
>> 
>> I just sent my last pull request to Linus, please merge it to
>> him directly.
>> 
>> Thanks.
> 
> I missed the opportunity. Could you pls queue the fix
> for next release and copy stable?

Ok, done.
