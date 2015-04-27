From: David Miller <davem@davemloft.net>
Subject: Re: [stable request] mlx4 & dev_kfree_skb
Date: Mon, 27 Apr 2015 12:26:46 -0400 (EDT)
Message-ID: <20150427.122646.1903715415529994914.davem@davemloft.net>
References: <20150421.143012.2106864724544609194.davem@davemloft.net>
	<553DFD1B.5000304@suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stable@vger.kernel.org, netdev@vger.kernel.org
To: jslaby@suse.cz
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <553DFD1B.5000304@suse.cz>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jiri Slaby <jslaby@suse.cz>
Date: Mon, 27 Apr 2015 11:10:51 +0200

> On 04/21/2015, 08:30 PM, David Miller wrote:
>> Please queue up the following networking bug fixes for 3.12, 3.14, 3.18,
>> 3.19, and 4.0 -stable, respectively.
> 
> Hi,
> 
> similar to other "Call dev_kfree_skby_any instead of dev_kfree_skb.", I
> believe, that mlx4 (only) in 3.14 should receive the fix too:

No, enough is enough.  I didn't even want to submit the first series you
asked for.
