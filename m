From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/14] net: info leaks and other bugs
Date: Wed, 15 Aug 2012 21:40:02 -0700 (PDT)
Message-ID: <20120815.214002.952465247315588940.davem@davemloft.net>
References: <1345066317-22512-1-git-send-email-minipli@googlemail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: minipli@googlemail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1345066317-22512-1-git-send-email-minipli@googlemail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mathias Krause <minipli@googlemail.com>
Date: Wed, 15 Aug 2012 23:31:43 +0200

> this series fixes quite a bunch of info leaks under net/. There is also
> one NULL pointer deref fix ("dccp: check ccid before..") that could be
> abused for privilege escalation.
> 
> The info leak fixes might be material for stable, too. But I leave the
> decision up to you.
> 
> On request, test code for all (but one) of the issues can be provided.

All applied and queued up for -stable, thanks a lot.
