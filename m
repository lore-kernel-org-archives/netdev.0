From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/2] enable hires timer to timeout datagram socket
Date: Fri, 08 Sep 2017 14:44:58 -0700 (PDT)
Message-ID: <20170908.144458.596885875256619458.davem@davemloft.net>
References: <1504891402.32080.5.camel@infradead.org>
        <20170908.102645.1086537961399780085.davem@davemloft.net>
        <20170908185521.GA12340@u40b0340c692b58f6553c.ant.amazon.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dwmw2@infradead.org, vallish@amazon.com, shuah@kernel.org,
        richardcochran@gmail.com, xiyou.wangcong@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        anchalag@amazon.com, dwmw@amazon.com
To: eduval@amazon.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170908185521.GA12340@u40b0340c692b58f6553c.ant.amazon.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eduardo Valentin <eduval@amazon.com>
Date: Fri, 8 Sep 2017 11:55:21 -0700

> I agree. I would prefer to understand here what is the technical
> reason not to accept these patches other than "use other system
> calls".

I explained this, let me reiterate:

====================
And most importantly, letting the kernel have flexibility in this area
is absolutely essential for various forms of optimizations and power
savings.
====================
