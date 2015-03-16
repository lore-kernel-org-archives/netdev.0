From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v2 0/3] switchdev: support stp updates on
 stacked netdevices
Date: Mon, 16 Mar 2015 07:37:49 +0100
Message-ID: <20150316063749.GA2032@nanopsycho.orion>
References: <20150313.123156.2118585119289960334.davem@davemloft.net>
 <CAE4R7bCvFPE5nPBJ7r41-ZC6=5AUE=gQ7uTy4kTNTZf-xKraVg@mail.gmail.com>
 <20150315191722.GE3518@nanopsycho.orion>
 <20150315.183213.1225773184212277874.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sfeldma@gmail.com, roopa@cumulusnetworks.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:33499 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751206AbbCPGhy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 02:37:54 -0400
Received: by wixw10 with SMTP id w10so24698273wix.0
        for <netdev@vger.kernel.org>; Sun, 15 Mar 2015 23:37:53 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150315.183213.1225773184212277874.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sun, Mar 15, 2015 at 11:32:13PM CET, davem@davemloft.net wrote:
>From: Jiri Pirko <jiri@resnulli.us>
>Date: Sun, 15 Mar 2015 20:17:22 +0100
>
>> Does that make sense? I think it is better just pick what we want to
>> support now and implement it there. That makes things clearer and
>> confusion-prone.
>
>You can't even say whether it makes sense or not, you yourself
>even have to ask.
>
>Again, I don't want to design our interfaces for potential needs,
>I want to design them for actually known needs.
>
>We'll deal with the discovered exceptions on an as-needed basis,
>not from the beginning.


Fair enough...
