From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RESEND] net: remove obsolete simple_strto<foo>
Date: Mon, 10 Dec 2012 23:48:17 -0500 (EST)
Message-ID: <20121210.234817.805113114715558868.davem@davemloft.net>
References: <1355130748-7828-1-git-send-email-abhi.c.pawar@gmail.com>
	<20121210.141002.450030380391247897.davem@davemloft.net>
	<50C6A995.1020908@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, kaber@trash.net, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, linville@tuxdriver.com,
	johannes@sipsolutions.net, amwang@redhat.com, edumazet@google.com,
	nhorman@tuxdriver.com, joe@perches.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netfilter@vger.kernel.org, coreteam@netfilter.org,
	linux-wireless@vger.kernel.org
To: abhi.c.pawar@gmail.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <50C6A995.1020908@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Abhijit Pawar <abhi.c.pawar@gmail.com>
Date: Tue, 11 Dec 2012 09:03:41 +0530

> On 12/11/2012 12:40 AM, David Miller wrote:
>> From: Abhijit Pawar <abhi.c.pawar@gmail.com>
>> Date: Mon, 10 Dec 2012 14:42:28 +0530
>> 
>>> This patch replace the obsolete simple_strto<foo> with kstrto<foo>
>>>
>>> Signed-off-by: Abhijit Pawar <abhi.c.pawar@gmail.com>
>> 
>> Applied.
>> 
> Hi David,
> It seems that there are occurences of simple_strto* still present in the
> couple of files which are not yet removed correctly by this patch. I
> will send a modified patch shortly. Please revert this commit and use
> the newly sent patch to merge with the tree.

Again, you cannot send "modified" patches.

When I say I've applied your patch, that cannot be undone.

You must therefore send me fixup patches relative to the ones
I've applied already.
