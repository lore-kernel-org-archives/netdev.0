From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH]: e1000 endianness bugs
Date: Wed, 15 Mar 2006 15:40:46 -0800 (PST)
Message-ID: <20060315.154046.130190626.davem@davemloft.net>
References: <20060315.142628.28661597.davem@davemloft.net>
	<4807377b0603151533i6a693d99ycdab71fe0a21dc4c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jeff@garzik.org, cramerj@intel.com, john.ronciak@intel.com,
	jesse.brandeburg@intel.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752175AbWCOXkw@vger.kernel.org>
To: jesse.brandeburg@gmail.com
In-Reply-To: <4807377b0603151533i6a693d99ycdab71fe0a21dc4c@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Jesse Brandeburg" <jesse.brandeburg@gmail.com>
Date: Wed, 15 Mar 2006 15:33:43 -0800

> Yep, those look like bugs to me, thanks and congratulations, you're
> the first person to test our PCI Express adapters in a big endian
> system (they haven't been available before, and we don't have one,
> yet)

It was onboard a Niagara T2000 system.
