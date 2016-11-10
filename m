From: David Miller <davem@davemloft.net>
Subject: Re: [Regression w/ patch] Restore network resistance to weird ICMP
 messages
Date: Thu, 10 Nov 2016 14:07:22 -0500 (EST)
Message-ID: <20161110.140722.1599944595520089484.davem@davemloft.net>
References: <CAO1wt+Z12-0vDVy2yo_L24Uesa688-wLfDb-CUZ5qmfRUF982Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: googuy@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAO1wt+Z12-0vDVy2yo_L24Uesa688-wLfDb-CUZ5qmfRUF982Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This is still not formed properly.

Your Subject line should be of the form:

	Subject: $Subsystem: $Description

Something like "icmp: Restore resistence to abnormal messages."

Also, your patch must be inline, right after the commit message,
rather than included as an attachment.

Finally your Fixes: line much be exactly right before the first
Signoff of your commit message.
