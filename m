From: David Miller <davem@davemloft.net>
Subject: Re: pull request: bluetooth-next 2015-03-19
Date: Thu, 19 Mar 2015 15:18:34 -0400 (EDT)
Message-ID: <20150319.151834.2088377056972130352.davem@davemloft.net>
References: <20150319145626.GA19462@t440s.P-661HNU-F1>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-bluetooth@vger.kernel.org
To: johan.hedberg@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49424 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750890AbbCSTSh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2015 15:18:37 -0400
In-Reply-To: <20150319145626.GA19462@t440s.P-661HNU-F1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johan Hedberg <johan.hedberg@gmail.com>
Date: Thu, 19 Mar 2015 16:56:26 +0200

> This wont the last 4.1 bluetooth-next pull request, but we've piled up
> enough patches in less than a week that I wanted to save you from a
> single huge "last-minute" pull somewhere closer to the merge window.
> 
> The main changes are:
> 
>  - Simultaneous LE & BR/EDR discovery support for HW that can do it
>  - Complete LE OOB pairing support
>  - More fine-grained mgmt-command access control (normal user can now do
>    harmless read-only operations).
>  - Added RF power amplifier support in cc2520 ieee802154 driver
>  - Some cleanups/fixes in ieee802154 code
> 
> Please let me know if there are any issues pulling. Thanks.

Pulled, thanks Johan.
