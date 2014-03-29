From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH 0/6 NEXT]staging: r8723au: Add new driver
Date: Fri, 28 Mar 2014 22:29:34 -0500
Message-ID: <53363E1E.6050308@lwfinger.net>
References: <1396060663-3589-1-git-send-email-Larry.Finger@lwfinger.net> <1396063566.31134.42.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, netdev@vger.kernel.org,
	devel@driverdev.osuosl.org, Jes Sorensen <Jes.Sorensen@redhat.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f50.google.com ([209.85.219.50]:54841 "EHLO
	mail-oa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751059AbaC2D3i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2014 23:29:38 -0400
Received: by mail-oa0-f50.google.com with SMTP id i7so6953352oag.23
        for <netdev@vger.kernel.org>; Fri, 28 Mar 2014 20:29:38 -0700 (PDT)
In-Reply-To: <1396063566.31134.42.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/28/2014 10:26 PM, Joe Perches wrote:
> On Fri, 2014-03-28 at 21:37 -0500, Larry Finger wrote:
>> The Realtek USB device RTL8723AU is found in Lenovo Yoga 13 tablets.
>> A driver for it has been available in a GitHub repo for several months.
> []
>>   133 files changed, 89878 insertions(+)
>
> eek.  realtek don't do small or concise.

No, they do not. Those 90 K lines are after Jes and I deleted several thousand 
lines. Of course, all these USB drivers have a complete MAC stack - they do not 
do mac80211. :(

Larry
