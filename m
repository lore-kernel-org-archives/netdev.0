From: David Miller <davem@davemloft.net>
Subject: Re: [BUG] net/ipv4: inconsistent routing table
Date: Tue, 11 Aug 2015 14:15:08 -0700 (PDT)
Message-ID: <20150811.141508.982016479032839502.davem@davemloft.net>
References: <CAOrge3pSQ7eck14biTncjOyGD-DKY0DvRr7JKpS3BowoSDry-Q@mail.gmail.com>
	<87y4hjgy6p.fsf@stressinduktion.org>
	<55CA608B.1070302@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, zealot0630@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: alexander.duyck@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55CA608B.1070302@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Tue, 11 Aug 2015 13:52:27 -0700

> On 08/10/2015 04:50 AM, Hannes Frederic Sowa wrote:
>>> 4. document it
>> I prefer that one :)
> 
> Yeah, me too.  The fact is things have worked this way up until now
> and I suspect the reason why this hasn't been reported until now is
> simply because in many cases it works since routes are usually updated
> if you are moving the gateway onto the local system.

+1
