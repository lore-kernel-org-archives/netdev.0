From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net/phy: Remove return value for a void function
Date: Tue, 01 Apr 2014 21:26:00 +0400
Message-ID: <533AF6A8.9080907@cogentembedded.com>
References: <1396362174-28775-1-git-send-email-Shruti@Freescale.com> <533ACE2D.6080403@Freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Emil Medve <Emilian.Medve@Freescale.com>, Shruti@Freescale.com,
	f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f44.google.com ([209.85.215.44]:44287 "EHLO
	mail-la0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751313AbaDAR0D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2014 13:26:03 -0400
Received: by mail-la0-f44.google.com with SMTP id c6so1013806lan.17
        for <netdev@vger.kernel.org>; Tue, 01 Apr 2014 10:26:01 -0700 (PDT)
In-Reply-To: <533ACE2D.6080403@Freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 04/01/2014 06:33 PM, Emil Medve wrote:

>> From: Shruti Kanetkar <Shruti@Freescale.com>

>> Change-Id: I03747d79beb1ef3a9e7fc8a11495196eabbed33f
>> Signed-off-by: Shruti Kanetkar <Shruti@Freescale.com>
>> Reviewed-on: http://git.am.freescale.net:8181/8914
>> Tested-by: Review Code-CDREVIEW <CDREVIEW@freescale.com>
>> Reviewed-by: Shruti Kanetkar <Shruti@freescale.com>

    What's that, self-review? :-)

> Please remove the internal Gerrit meta and re-send

    Change-Id is OK for networking patches, DaveM has approved its use.
Reviewed-on is something new though...

WBR, Sergei
