From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: query: net-next section mismatch(es)
Date: Mon, 09 Nov 2009 06:36:37 -0500
Message-ID: <4AF7FEC5.40001@gmail.com>
References: <4AF6D1F5.80307@gmail.com>	<20091108.163527.185100796.davem@davemloft.net>	<4AF777FC.4080805@gmail.com> <87k4y056q2.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f187.google.com ([209.85.210.187]:47656 "EHLO
	mail-yx0-f187.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750729AbZKILgb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Nov 2009 06:36:31 -0500
Received: by yxe17 with SMTP id 17so2459904yxe.33
        for <netdev@vger.kernel.org>; Mon, 09 Nov 2009 03:36:37 -0800 (PST)
In-Reply-To: <87k4y056q2.fsf@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andi Kleen wrote:
> You should report those to the respective maintainers of the code that throws
> the warning (see MAINTAINERS) and to linux-kernel. This is not really related
> to networking.
> 
Thanks.  I'll do that.  I reported it here, as it was a fairly significant
change to net-next, and I assumed it was probably due to some recent problem
importing/merging some other branch into this one.  But that's just a guess,
so it's phrased as a query....
