From: David Miller <davem@davemloft.net>
Subject: Re: PATCH drivers:net:cris/eth_v10: alternate string char arrary
Date: Mon, 24 Apr 2017 14:18:58 -0400 (EDT)
Message-ID: <20170424.141858.74081542058277927.davem@davemloft.net>
References: <1493056179-6460-1-git-send-email-karim.eshapa@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: felipe.balbi@linux.intel.com, paul.gortmaker@windriver.com,
        mugunthanvnm@ti.com, jarod@redhat.com, fw@strlen.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: karim.eshapa@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1493056179-6460-1-git-send-email-karim.eshapa@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Karim Eshapa <karim.eshapa@gmail.com>
Date: Mon, 24 Apr 2017 19:49:39 +0200

> static char pointer creates two variables in final assembly.
> static string and pointer to it according to
> Jeff Garzik janitors TODO.
> 
> Signed-off-by: Karim Eshapa <karim.eshapa@gmail.com>

Instead of trusting some document written more than 10 years ago on
the internet, why don't you build the source file in question and take
a look at what actually happens?

I'm not applying this, sorry.
