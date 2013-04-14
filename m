From: Dash Four <mr.dash.four@googlemail.com>
Subject: Re: [PATCH v2] iproute2: lib/utils.c bug fixes
Date: Sun, 14 Apr 2013 20:34:22 +0100
Message-ID: <516B04BE.6030302@googlemail.com>
References: <516AB8EE.5090901@googlemail.com> <20130414100000.3b73fa36@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:40372 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753106Ab3DNTe2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Apr 2013 15:34:28 -0400
Received: by mail-wi0-f174.google.com with SMTP id hj8so937872wib.1
        for <netdev@vger.kernel.org>; Sun, 14 Apr 2013 12:34:27 -0700 (PDT)
In-Reply-To: <20130414100000.3b73fa36@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> Thanks for your patch. there were lots of related over/underflow errors in
> this code which have existed for a long time. I took your patch as motivation
> and did multiple fixes to add error checking for all the cases present.
>   
That's good. Do you have the git url (or any other repository I could 
fetch these from) so that I could apply these changes on our machines 
here? I checked on 
http://git.kernel.org/cgit/linux/kernel/git/shemminger/iproute2.git but 
it looks as though the last commit was done 41 hours ago.

> Thank you.
>   
Pleasure!
