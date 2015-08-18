From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] r8169:Set RxConfig on same func. with TxConfig
Date: Tue, 18 Aug 2015 12:42:32 -0700 (PDT)
Message-ID: <20150818.124232.176851590301929849.davem@davemloft.net>
References: <1439925021-5772-1-git-send-email-corcodel.marian@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: corcodel.marian@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41887 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752891AbbHRTmf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Aug 2015 15:42:35 -0400
In-Reply-To: <1439925021-5772-1-git-send-email-corcodel.marian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Corcodel Marian <corcodel.marian@gmail.com>
Date: Tue, 18 Aug 2015 22:10:21 +0300

>  Add set DMA burst size and  Rx FIFO threshold on RxConfig  
>   register to function rtl_set_rx_tx_config_register.
> 
> 
> Signed-off-by: Corcodel Marian <corcodel.marian@gmail.com>

I would like to politely ask you to stop submitting these r8169 patches
right now.

Your method of handling your patch submissions is not acceptable and
is scarily wasting developer resources every single day.

When people give you feedback about why your patch is not correct, or
ask you questions, you often do not respond.  Or, if you do respond,
you give a very small response that do not actually answer the
question given to you.

When people give feedback to your patch, you _MUST_ engage in a
coherent full conversation with the person giving you feedback.

It is not acceptable to just ignore what that person tells you,
or to be quiet.  You cannot just keep throwing patches blindly
to this mailing list.

It is especially not acceptable to ignore feedback, and then keep
submitting more and more patches.  This is the worst thing in the
world that you can do.

You are creating a situation where the people trying to help you by
reviewing your work feel like they are wasting their time.

Furthermore, you haven't answered the most basic question we have
asked you.  Where are all of these r1869 patches coming from?  What is
the reason why you are looking into all of the r8169 issues all of a
sudden?  It looks very random and strange to all of us.
