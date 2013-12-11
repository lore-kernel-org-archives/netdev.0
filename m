From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] micrel: add support for KSZ8041RNLI
Date: Wed, 11 Dec 2013 17:10:05 -0500 (EST)
Message-ID: <20131211.171005.1026686921972557583.davem@davemloft.net>
References: <52A8D90F.9090002@cogentembedded.com>
	<20131211.161146.379334754489134708.davem@davemloft.net>
	<52A8EEF8.3090503@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org
To: sergei.shtylyov@cogentembedded.com
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <52A8EEF8.3090503@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Thu, 12 Dec 2013 02:02:16 +0300

>    Well, the R8A7791 Ether platform support should appear only in 3.14,
>    so don't bother. I just wanted to understand the principle you
>    follow...

Generally speaking, if the change to support a new device is simply
a matter of adding a new device ID I tend to queue it up for 'net'.
