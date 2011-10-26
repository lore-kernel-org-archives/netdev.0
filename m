From: David Miller <davem@davemloft.net>
Subject: Re: asix usb network driver: nfg
Date: Wed, 26 Oct 2011 19:40:45 -0400 (EDT)
Message-ID: <20111026.194045.2019668159403582571.davem@davemloft.net>
References: <4EA89972.5060101@teksavvy.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: kernel@teksavvy.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4EA89972.5060101@teksavvy.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mark Lord <kernel@teksavvy.com>
Date: Wed, 26 Oct 2011 19:36:18 -0400

> So, the in-kernel asix driver seems badly broken for a lot of hardware,
> and the vendor driver also has a slight race somewhere that is cured
> by enabling debug logging.
> 
> Is there an asix driver maintainer, or anyone else with the time
> to step up and try to fix these issues?

The issues you speak of are well known for at least two years but
nobody wants to work on this.
