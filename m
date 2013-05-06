From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH RFT] 3c59x: fix freeing nonexistent resource on driver
 unload
Date: Tue, 07 May 2013 01:49:17 +0400
Message-ID: <5188255D.4000702@cogentembedded.com>
References: <201305030110.22462.sergei.shtylyov@cogentembedded.com> <20130506.122236.49412750367407481.davem@davemloft.net> <5188166A.2050200@cogentembedded.com> <20130506.165018.1267090005146246869.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, klassert@mathematik.tu-chemnitz.de,
	tedheadster@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f180.google.com ([209.85.217.180]:64926 "EHLO
	mail-lb0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757795Ab3EFVtT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 May 2013 17:49:19 -0400
Received: by mail-lb0-f180.google.com with SMTP id v1so47598lbd.39
        for <netdev@vger.kernel.org>; Mon, 06 May 2013 14:49:18 -0700 (PDT)
In-Reply-To: <20130506.165018.1267090005146246869.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/07/2013 12:50 AM, David Miller wrote:

>
>>     Will you queue this patch for stable?
> Done.

    Thank you. It's really ancient error, though for the ancient boards 
only as well...

WBR, Sergei
