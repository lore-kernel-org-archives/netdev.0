From: Sakari Ailus <sakari.ailus@iki.fi>
Subject: Re: [PATCH v2 2/2] tlan: add suspend/resume support
Date: Tue, 25 Jan 2011 10:44:26 +0200
Message-ID: <4D3E8D6A.5040705@iki.fi>
References: <4D39F3A7.9050106@iki.fi>	<1295643571-21216-1-git-send-email-sakari.ailus@iki.fi>	<1295643571-21216-2-git-send-email-sakari.ailus@iki.fi> <20110124.150728.246519223.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, chessman@tux.org, joe@perches.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-68.nebula.fi ([83.145.220.68]:46474 "EHLO
	smtp-68.nebula.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753020Ab1AYIo3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jan 2011 03:44:29 -0500
In-Reply-To: <20110124.150728.246519223.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Sakari Ailus<sakari.ailus@iki.fi>
> Date: Fri, 21 Jan 2011 22:59:31 +0200
>
>> Add suspend/resume support to tlan driver. This allows not unloading the
>> driver over suspend/resume.
>>
>> Also, start (or now, wake) the queue after resetting the adapter --- not the
>> other way around.
>>
>> Signed-off-by: Sakari Ailus<sakari.ailus@iki.fi>
>
> Applied.

Thanks, David!

-- 
Sakari Ailus
sakari.ailus@iki.fi
