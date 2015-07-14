From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ravb: kill useless initializers
Date: Tue, 14 Jul 2015 15:37:47 -0700 (PDT)
Message-ID: <20150714.153747.1713328371232217300.davem@davemloft.net>
References: <3087282.SVZhuJYtXK@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org
To: sergei.shtylyov@cogentembedded.com
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <3087282.SVZhuJYtXK@wasted.cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Fri, 10 Jul 2015 21:10:10 +0300

> Some of the local variable intializers in the driver turned out to be pointless,
> kill them.
> 
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Applied, thanks.
