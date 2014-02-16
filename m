From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH 02/13] staging: r8188eu: Remove pointless "alignment"
 entry in recv_frame
Date: Sun, 16 Feb 2014 10:26:19 -0600
Message-ID: <5300E6AB.7010704@lwfinger.net>
References: <1392418457-3203-1-git-send-email-Larry.Finger@lwfinger.net> <1392418457-3203-3-git-send-email-Larry.Finger@lwfinger.net> <87ob27bvz7.fsf@will.lan> <20140216090956.GG26722@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, gregkh@linuxfoundation.org,
	Jes.Sorensen@redhat.com, netdev@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>,
	"Zhao, Gang" <gamerh2o@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f41.google.com ([209.85.219.41]:58499 "EHLO
	mail-oa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752474AbaBPQ0W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Feb 2014 11:26:22 -0500
Received: by mail-oa0-f41.google.com with SMTP id j17so16619526oag.14
        for <netdev@vger.kernel.org>; Sun, 16 Feb 2014 08:26:21 -0800 (PST)
In-Reply-To: <20140216090956.GG26722@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/16/2014 03:09 AM, Dan Carpenter wrote:
> On Sun, Feb 16, 2014 at 11:02:52AM +0800, Zhao, Gang wrote:
>> On Sat, 2014-02-15 at 06:54:06 +0800, Larry Finger wrote:
>>> This alignment entry in union recv_frame does nothing. It certainly
>>> dues not ensure alignment.
>>     ^
>>     typo here.
>>
>>     I accidently sent this as a private mail before, better to resend to
>>     the list.
>>
>
> This was already applied.  You can still understand the meaning so it's
> fine.  No need to redo.  Typos in the code are more important.
>
> It's hard to run spell checkers on patches since so much of the words
> are code and not English.

In addition, this typo resulted in a correctly spelled word. It was just the 
wrong one.

Larry
