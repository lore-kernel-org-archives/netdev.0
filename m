From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] r8169: Fix WoL on RTL8168d/8111d.
Date: Sat, 03 Nov 2012 15:16:59 -0400 (EDT)
Message-ID: <20121103.151659.1731852488102322283.davem@davemloft.net>
References: <20121028230523.GA26778@electric-eye.fr.zoreil.com>
	<1351728046-32105-1-git-send-email-kibi@debian.org>
	<20121101222113.GB7708@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kibi@debian.org, netdev@vger.kernel.org, nic_swsd@realtek.com,
	hayeswang@realtek.com, linux-kernel@vger.kernel.org,
	florent.fourcot@enst-bretagne.fr
To: romieu@fr.zoreil.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20121101222113.GB7708@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Thu, 1 Nov 2012 23:21:13 +0100

> Cyril Brulebois <kibi@debian.org> :
>> This regression was spotted between Debian squeeze and Debian wheezy
>> kernels (respectively based on 2.6.32 and 3.2). More info about
>> Wake-on-LAN issues with Realtek's 816x chipsets can be found in the
>> following thread: http://marc.info/?t=132079219400004
> 
> David, please apply to -net.

Done.
