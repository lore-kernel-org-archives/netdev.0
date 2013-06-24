From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: Re: [PATCH v3 net-next 0/1] net: lls select poll support
Date: Mon, 24 Jun 2013 07:23:27 +0300
Message-ID: <51C7C9BF.5090305@linux.intel.com>
References: <20130619100421.22132.99447.stgit@ladj378.jer.intel.com> <20130623.184437.1772856342146874217.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jesse.brandeburg@intel.com, donald.c.skidmore@intel.com,
	e1000-devel@lists.sourceforge.net, willemb@google.com,
	erdnetdev@gmail.com, bhutchings@solarflare.com,
	andi@firstfloor.org, hpa@zytor.com, eilong@broadcom.com,
	or.gerlitz@gmail.com, amirv@mellanox.com, alexr@mellanox.com,
	eliezer@tamir.org.il
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130623.184437.1772856342146874217.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 24/06/2013 04:44, David Miller wrote:
> From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
> Date: Wed, 19 Jun 2013 13:04:21 +0300
>
>> One question: do we need in sock_poll() to test that sock->sk is not null?
>> (Thanks to Willem de Bruijn for pointing this out.)
>
> We should not have to.
>
> Please clean up various things in this patch:

Ok,
Thanks!
