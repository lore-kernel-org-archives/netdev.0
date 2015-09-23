From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next 2/9] net: Remove e_inval label from
 ip_route_input_slow
Date: Wed, 23 Sep 2015 15:26:09 -0700
Message-ID: <56032701.7040604@gmail.com>
References: <1443021322-48621-1-git-send-email-dsa@cumulusnetworks.com>
 <1443021322-48621-3-git-send-email-dsa@cumulusnetworks.com>
 <5602C901.2050404@gmail.com> <5602CD17.3030008@cumulusnetworks.com>
 <5602D3CA.7010502@gmail.com> <5602DDC1.2080403@cumulusnetworks.com>
 <5602E39D.6060509@gmail.com> <5602E957.2060409@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: David Ahern <dsa@cumulusnetworks.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:34357 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754112AbbIWW0M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 18:26:12 -0400
Received: by padhy16 with SMTP id hy16so52392916pad.1
        for <netdev@vger.kernel.org>; Wed, 23 Sep 2015 15:26:11 -0700 (PDT)
In-Reply-To: <5602E957.2060409@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/23/2015 11:03 AM, David Ahern wrote:
> If you have a better suggestion for how to improve this code then 
> please submit it. I don't have a religion here. I don't like making 
> mistakes and the silly mistake that led to bde6f9ded1 motivated this 
> patch series.

I'll take a stab at it.  If you don't mind I might pull in a couple of 
your patches and make a few tweaks here and there and I will resubmit 
them with a few others.

Thanks.

- Alex
