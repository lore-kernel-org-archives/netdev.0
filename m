From: Daniel Mack <zonque@gmail.com>
Subject: Re: [PATCH 1/3] net: of_mdio: factor out code to parse a phy's 'reg'
 property
Date: Tue, 13 May 2014 19:29:37 +0200
Message-ID: <53725681.6080804@gmail.com>
References: <536E8C0E.3040407@cogentembedded.com>	<20140513.130738.453141636294063523.davem@davemloft.net>	<537254B2.9050600@gmail.com> <20140513.132500.1690426507365800424.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: sergei.shtylyov@cogentembedded.com, f.fainelli@gmail.com,
	netdev@vger.kernel.org, mugunthanvnm@ti.com, ujhelyi.m@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f41.google.com ([74.125.83.41]:49159 "EHLO
	mail-ee0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751270AbaEMR3k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2014 13:29:40 -0400
Received: by mail-ee0-f41.google.com with SMTP id t10so655987eei.28
        for <netdev@vger.kernel.org>; Tue, 13 May 2014 10:29:39 -0700 (PDT)
In-Reply-To: <20140513.132500.1690426507365800424.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/13/2014 07:25 PM, David Miller wrote:
> From: Daniel Mack <zonque@gmail.com>

>> Yes, I agree as well, but I guess I can add this as a follow-up patch,
>> so we have it separate from the code move?
> 
> Please repost the patch series with the requested changes made, no need
> to start with excessive code from the beginning only to remove it.

Ok, no problem. I'll wait for Florian's test results and repost.


Thanks for the input, everyone!
Daniel
