From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v3] net: Add fib rules at vrf device create
Date: Wed, 9 Dec 2015 16:04:53 -0700
Message-ID: <5668B395.2030604@cumulusnetworks.com>
References: <1449683012-14145-1-git-send-email-dsa@cumulusnetworks.com>
 <20151209.151309.1866782058292162458.davem@davemloft.net>
 <5668A592.3080104@cumulusnetworks.com>
 <20151209.172207.663308411545854156.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shm@cumulusnetworks.com,
	roopa@cumulusnetworks.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f175.google.com ([209.85.214.175]:32902 "EHLO
	mail-ob0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751422AbbLIXE4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2015 18:04:56 -0500
Received: by obbww6 with SMTP id ww6so47328080obb.0
        for <netdev@vger.kernel.org>; Wed, 09 Dec 2015 15:04:56 -0800 (PST)
In-Reply-To: <20151209.172207.663308411545854156.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/9/15 3:22 PM, David Miller wrote:
> Just write a script already...

Why do you think this took so long to bubble up?

I wrote a script back in July -- well before VRF was accepted into your 
tree -- that I use for testing. This request comes from other users 
starting to work with VRFs.
