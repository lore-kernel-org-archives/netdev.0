From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] tcp: ioctl type SIOCOUTQNSD returns amount of data
 not sent
Date: Wed, 09 Mar 2011 14:09:51 -0800 (PST)
Message-ID: <20110309.140951.232741403.davem@davemloft.net>
References: <20110304123950.2c91ebd9@lxorguk.ukuu.org.uk>
	<1299441595-18455-1-git-send-email-sledz@dresearch.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	alan@lxorguk.ukuu.org.uk, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	m.schuknecht@dresearch.de
To: sledz@dresearch.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1299441595-18455-1-git-send-email-sledz@dresearch.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Steffen Sledz <sledz@dresearch.de>
Date: Sun,  6 Mar 2011 20:59:55 +0100

> From: Mario Schuknecht <m.schuknecht@dresearch.de>
> 
> In contrast to SIOCOUTQ which returns the amount of data sent
> but not yet acknowledged plus data not yet sent this patch only
> returns the data not sent.
> 
> For various methods of live streaming bitrate control it may
> be helpful to know how much data are in the tcp outqueue are
> not sent yet.
> 
> Signed-off-by: Mario Schuknecht <m.schuknecht@dresearch.de>
> Signed-off-by: Steffen Sledz <sledz@dresearch.de>

Applied, thanks.
