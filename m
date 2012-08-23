From: Chris Friesen <chris.friesen@genband.com>
Subject: Re: wireless router performance differ with 2.4Ghz vs 5.0Ghz frequency
Date: Thu, 23 Aug 2012 09:23:16 -0600
Message-ID: <50364AE4.9050401@genband.com>
References: <CAF1ivSZ63Zr9STz3NnLV=ynRftMokG=ZGghd+cQu=HRUsiH+EA@mail.gmail.com> <CAGRGNgWddAH3UyYq5T7iT+FuX8ajdGpP6rfjjCUkZZpiCoTmpQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Lin Ming <mlin@ss.pku.edu.cn>, linux-wireless@vger.kernel.org,
	networking <netdev@vger.kernel.org>
To: Julian Calaby <julian.calaby@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og102.obsmtp.com ([64.18.2.157]:54205 "EHLO
	exprod7og102.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756223Ab2HWPXy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 11:23:54 -0400
In-Reply-To: <CAGRGNgWddAH3UyYq5T7iT+FuX8ajdGpP6rfjjCUkZZpiCoTmpQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/23/2012 04:34 AM, Julian Calaby wrote:
> Hi,
>
> On Thu, Aug 23, 2012 at 2:50 PM, Lin Ming<mlin@ss.pku.edu.cn>  wrote:
>> Hi list,
>>
>> I have a wireless router with 2 wireless cards: 2.4Ghz and 5.0Ghz frequency.
>>
>> The performance for 2.4Ghz is much worse than 5.0Ghz.
>>
>> Does the frequency affect performance so much?
> There are a lot of factors:
> - Amounts of other networks on the same channel
> - Noise
> - Signal strength
> etc.
>
> It's quite possible that there are less networks on 5GHz channels
> where you are so there's less noise, stronger signal, and therefore
> better performance. Most routers are still only 2.4GHz.

In addition to this you may wish to check your channel width.  You may 
be using 40MHz channels on 5GHz and 20MHz channels on 2.4GHz.

Chris
