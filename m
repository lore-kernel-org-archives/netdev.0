From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v1 2/2] netpoll: avoid reference leaks
Date: Tue, 08 Jul 2014 15:16:09 -0700 (PDT)
Message-ID: <20140708.151609.2007775439986953108.davem@davemloft.net>
References: <CAG88wWZ9GiqoOscqG4-ePOWo8bXgSTAQ6=6-tZPahMcxOvQMLg@mail.gmail.com>
	<20140708.141708.2064358397103630362.davem@davemloft.net>
	<CAG88wWa9WTz4gwLHWAys1e96eWBgD+mcVW=hPh7a+b2ooJzBeQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ebiederm@xmission.com, edumazet@google.com, amwang@redhat.com,
	antonio@meshcoding.com, jpirko@redhat.com
To: decot@googlers.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAG88wWa9WTz4gwLHWAys1e96eWBgD+mcVW=hPh7a+b2ooJzBeQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Decotigny <decot@googlers.com>
Date: Tue, 8 Jul 2014 14:50:24 -0700

> In that case, that's what the original code does: dropping this patch 2/2.
> 
> Patch 1/2 "netpoll: fix use after free" is still needed to prevent
> panics, though.

Please resubmit it then.
