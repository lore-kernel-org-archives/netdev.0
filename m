From: roopa <roopa@cumulusnetworks.com>
Subject: Re: kernel 4.2 : "bridge vlan" command return empty result (works
 with kernel 4.1.3)
Date: Wed, 16 Sep 2015 22:33:37 -0700
Message-ID: <55FA50B1.8060707@cumulusnetworks.com>
References: <1167950469.57377315.1442338762965.JavaMail.zimbra@oxygem.tv> <55F86B4A.7090001@cumulusnetworks.com> <1679804272.62090915.1442461016457.JavaMail.zimbra@oxygem.tv>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Scott Feldman <sfeldma@cumulusnetworks.com>
To: Alexandre DERUMIER <aderumier@odiso.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:33945 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752225AbbIQFdj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Sep 2015 01:33:39 -0400
Received: by padhy16 with SMTP id hy16so10252244pad.1
        for <netdev@vger.kernel.org>; Wed, 16 Sep 2015 22:33:38 -0700 (PDT)
In-Reply-To: <1679804272.62090915.1442461016457.JavaMail.zimbra@oxygem.tv>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/16/15, 8:36 PM, Alexandre DERUMIER wrote:
>>> he problem went away on my box with the following patch. I
>>> will submit an official patch in a bit.
> Hi, I confirm that your patch fix the problem for me too.
>
Thanks for confirming.
