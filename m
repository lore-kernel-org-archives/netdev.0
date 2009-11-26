From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv3 0/4] macvlan: add vepa and bridge mode
Date: Thu, 26 Nov 2009 15:53:14 -0800 (PST)
Message-ID: <20091126.155314.201869723.davem@davemloft.net>
References: <1259251631-11617-1-git-send-email-arnd@arndb.de>
	<4B0EAC29.60601@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arnd@arndb.de, netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	eric.dumazet@gmail.com, anna.fischer@hp.com,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	lk-netdev@lk-netdev.nosense.org, gerhard.stenzel@de.ibm.com,
	ebiederm@xmission.com, jens@linux.vnet.ibm.com,
	pmullaney@novell.com, shemminger@vyatta.com
To: kaber@trash.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752498AbZKZXw5@vger.kernel.org>
In-Reply-To: <4B0EAC29.60601@trash.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Thu, 26 Nov 2009 17:26:17 +0100

> Arnd Bergmann wrote:
>> Version 2 description:
>> The patch to iproute2 has not changed, so I'm not including
>> it this time. Patch 4/4 (the netlink interface) is basically
>> unchanged as well but included for completeness.
>> 
>> The other changes have moved forward a bit, to the point where
>> I find them a lot cleaner and am more confident in the code
>> being ready for inclusion. The implementation hardly resembles
>> Erics original patch now, so I've dropped his signed-off-by.
>> 
>> Please take a look and ack if you are happy so we can get it
>> into 2.6.33.
> 
> Looks good to me, nice work.
> 
> Acked-by: Patrick McHardy <kaber@trash.net>
> 
> for the entire series.

All applied to net-next-2.6, thanks everyone!
