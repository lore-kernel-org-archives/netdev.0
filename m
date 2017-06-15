From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH iproute2] link_gre6: really support encaplimit option
Date: Thu, 15 Jun 2017 09:28:46 +0200
Message-ID: <012103d8-0ba0-10ea-1a5a-ef72871bc293@6wind.com>
References: <1497458742-6068-1-git-send-email-nicolas.dichtel@6wind.com>
 <20170614133118.482b3c59@xeon-e3>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f170.google.com ([209.85.128.170]:33551 "EHLO
        mail-wr0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750861AbdFOH2o (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 03:28:44 -0400
Received: by mail-wr0-f170.google.com with SMTP id r103so9022639wrb.0
        for <netdev@vger.kernel.org>; Thu, 15 Jun 2017 00:28:43 -0700 (PDT)
In-Reply-To: <20170614133118.482b3c59@xeon-e3>
Content-Language: fr
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 14/06/2017 à 22:31, Stephen Hemminger a écrit :
> On Wed, 14 Jun 2017 18:45:42 +0200
> Nicolas Dichtel <nicolas.dichtel@6wind.com> wrote:
> 
>> This option is documented in gre6 help, but was not supported.
>>
>> Fixes: af89576d7a8c ("iproute2: GRE over IPv6 tunnel support.")
>> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> 
> Sure applied.
> 
Thank you. It seems that your iproute2 tree on kernel.org is not up to date, the
last patch has been pushed one week ago.


Regards,
Nicolas
