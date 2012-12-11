From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RESEND] net: remove obsolete simple_strto<foo>
Date: Mon, 10 Dec 2012 23:43:58 -0500 (EST)
Message-ID: <20121210.234358.788502498079611342.davem@davemloft.net>
References: <1355130748-7828-1-git-send-email-abhi.c.pawar@gmail.com>
	<20121210.141002.450030380391247897.davem@davemloft.net>
	<CA+kxV1GBxdZKnjqs1bm1qBJE8dGXtOfqP_oYbB-hw5Ga1xE65g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: amwang@redhat.com, joe@perches.com, jmorris@namei.org,
	edumazet@google.com, pablo@netfilter.org, kaber@trash.net,
	coreteam@netfilter.org, yoshfuji@linux-ipv6.org,
	netfilter-devel@vger.kernel.org, johannes@sipsolutions.net,
	linux-kernel@vger.kernel.org, netfilter@vger.kernel.org,
	linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, nhorman@tuxdriver.com, kuznet@ms2.inr.ac.ru
To: abhi.c.pawar@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+kxV1GBxdZKnjqs1bm1qBJE8dGXtOfqP_oYbB-hw5Ga1xE65g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Abhijit Pawar <abhi.c.pawar@gmail.com>
Date: Tue, 11 Dec 2012 06:36:59 +0530

> It looks like there are two occurences of simple_strtoul which has not been
> removed cleanly from the patch.
> They are in netpoll.c and debugfs_sta.c
> I will send the modified corrected clean patch shortly.

You can't simply send me a replacement patch, since I already applied
the original one and that patch will not be reverted.
