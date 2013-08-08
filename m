From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: Tree for Aug 7
Date: Wed, 07 Aug 2013 17:09:26 -0700 (PDT)
Message-ID: <20130807.170926.319558320779361738.davem@davemloft.net>
References: <20130807.162748.779496444843938176.davem@davemloft.net>
	<20130807.163621.84433966934449459.davem@davemloft.net>
	<CA+icZUUm2nbmVj_WRznPTjXL0y6pcr1GzLjsL7UMhSGQWSm==g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: phil@nwl.cc, eric.dumazet@gmail.com, johannes@sipsolutions.net,
	sfr@canb.auug.org.au, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	hannes@stressinduktion.org, linux-wireless@vger.kernel.org,
	linville@tuxdriver.com
To: sedat.dilek@gmail.com
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <CA+icZUUm2nbmVj_WRznPTjXL0y6pcr1GzLjsL7UMhSGQWSm==g@mail.gmail.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sedat Dilek <sedat.dilek@gmail.com>
Date: Thu, 8 Aug 2013 02:02:48 +0200

> On Thu, Aug 8, 2013 at 1:36 AM, David Miller <davem@davemloft.net> wrote:
>> From: David Miller <davem@davemloft.net>
>> Date: Wed, 07 Aug 2013 16:27:48 -0700 (PDT)
>>
>>> Look, I'm going to fix this myself, because I'm pretty tired of
>>> waiting for the obvious fix.
>>
>> Someone please test this:
> 
> Your patch on top of next-20130807 does not fix the issue in my wifi/network.
> No working Internet connection (ping etc.).

Ok, I'm going to simply revert all of these changes, thanks for testing.
