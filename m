From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next] Revert "bnx2x: allow nvram test to run when
 device is down"
Date: Wed, 01 May 2013 00:09:47 +0400
Message-ID: <5180250B.3010703@cogentembedded.com>
References: <1367314447-10518-1-git-send-email-dmitry@broadcom.com> <20130430.154916.289965268165509683.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: dmitry@broadcom.com, netdev@vger.kernel.org, eilong@broadcom.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f173.google.com ([209.85.217.173]:56682 "EHLO
	mail-lb0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933058Ab3D3UJy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Apr 2013 16:09:54 -0400
Received: by mail-lb0-f173.google.com with SMTP id v5so916052lbc.32
        for <netdev@vger.kernel.org>; Tue, 30 Apr 2013 13:09:53 -0700 (PDT)
In-Reply-To: <20130430.154916.289965268165509683.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 04/30/2013 11:49 PM, David Miller wrote:

>
>> This reverts commit d2d2d87dfd1a25ee270994c5b9e3eb4690428d32.
> Please refer to commits in the following format:
>
> ${SHA_ID} ("Commit message header line.")

    David, this is a standard revert changelog format, reverted commit's 
summary is in the subject.

WBR, Sergei
