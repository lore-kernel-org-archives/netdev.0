From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: smsc911x: fix RX FIFO fastforwarding when
 dropping packets
Date: Thu, 12 Apr 2012 19:41:40 +0200
Message-ID: <1334252500.5300.6929.camel@edumazet-glaptop>
References: <1334221644-16056-1-git-send-email-will.deacon@arm.com>
	 <1334222448.5300.6046.camel@edumazet-glaptop>
	 <20120412125355.GG16025@mudshark.cambridge.arm.com>
	 <1334235963.5300.6361.camel@edumazet-glaptop>
	 <20120412134757.GH16025@mudshark.cambridge.arm.com>
	 <1334239299.5300.6478.camel@edumazet-glaptop>
	 <20120412155409.GA28204@mudshark.cambridge.arm.com>
	 <1334246880.5300.6736.camel@edumazet-glaptop>
	 <20120412170350.GD28204@mudshark.cambridge.arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Steve Glendinning <steve.glendinning@smsc.com>
To: Will Deacon <will.deacon@arm.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:39638 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757934Ab2DLRls (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Apr 2012 13:41:48 -0400
Received: by bkcik5 with SMTP id ik5so1723332bkc.19
        for <netdev@vger.kernel.org>; Thu, 12 Apr 2012 10:41:43 -0700 (PDT)
In-Reply-To: <20120412170350.GD28204@mudshark.cambridge.arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-04-12 at 18:03 +0100, Will Deacon wrote:


> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> 
> Thanks, Eric. Given that Steve's email doesn't appear to be working, can
> somebody else pick this up please?

It seems trivial enough, you tested it, and I reviewed it.

I believe David can apply it safely.

Thanks
