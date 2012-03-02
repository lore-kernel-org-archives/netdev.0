From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/10] af_unix: add multicast and filtering features to
 AF_UNIX
Date: Fri, 02 Mar 2012 04:39:27 -0500 (EST)
Message-ID: <20120302.043927.1075141476785695419.davem@davemloft.net>
References: <CABBYNZLwHKd5srzYYzWNL-iaeuH1K31824pY_bjRSbSLkv0QtA@mail.gmail.com>
	<20120302.035509.1994457175982020283.davem@davemloft.net>
	<4F509274.9060302@collabora.co.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, ying.xue@windriver.com,
	luiz.dentz@gmail.com, eric.dumazet@gmail.com,
	rodrigo.moya@collabora.co.uk, javier@collabora.co.uk,
	lennart@poettering.net, kay.sievers@vrfy.org,
	alban.crequy@collabora.co.uk, bart.cerneels@collabora.co.uk,
	sjoerd.simons@collabora.co.uk, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: javier.martinez@collabora.co.uk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4F509274.9060302@collabora.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Javier Martinez Canillas <javier.martinez@collabora.co.uk>
Date: Fri, 02 Mar 2012 10:27:16 +0100

> Do you think that a simpler AF_UNIX multicast implementation without the
> locking to guarantee order delivery and the flow control that blocks the
> sender can be resend to you to reconsider merging it?

No.
