From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: md5: check md5 signature without socket
 lock
Date: Wed, 06 Aug 2014 14:35:43 -0700 (PDT)
Message-ID: <20140806.143543.1816769049569901557.davem@davemloft.net>
References: <20140805025452.1a5bec4ad0d0c5a30a22a589@qrator.net>
	<20140805.162703.362629415553579077.davem@davemloft.net>
	<20140806224902.180d8bbee02b9f4ce82cbe5c@qrator.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: ixaphire@qrator.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140806224902.180d8bbee02b9f4ce82cbe5c@qrator.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dmitry Popov <ixaphire@qrator.net>
Date: Wed, 6 Aug 2014 22:49:02 +0400

> It seems your arguments are based on the assumption that I moved md5 signature
> check down the tcp processing chain. But I did exactly the opposite, md5 is
> checked earlier in this patch.

Ok, now I understand, thanks for explaining.

Please resubmit your patch, I'll apply it.

Thank you.
