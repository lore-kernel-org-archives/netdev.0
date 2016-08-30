From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net 1/2] ipv6: add missing netconf notif when 'all' is
 updated
Date: Tue, 30 Aug 2016 09:41:53 +0200
Message-ID: <73a53b3c-a782-7ed1-9915-419981fb8cfe@6wind.com>
References: <1472465149-1163-1-git-send-email-nicolas.dichtel@6wind.com>
 <21983bb4-de14-6811-865d-12f114f573b0@miraclelinux.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>,
        davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:37782 "EHLO
        mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752756AbcH3Hl6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2016 03:41:58 -0400
Received: by mail-wm0-f47.google.com with SMTP id i5so20545766wmg.0
        for <netdev@vger.kernel.org>; Tue, 30 Aug 2016 00:41:57 -0700 (PDT)
In-Reply-To: <21983bb4-de14-6811-865d-12f114f573b0@miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 30/08/2016 à 04:51, YOSHIFUJI Hideaki a écrit :
> 
> 
> Nicolas Dichtel wrote:
[snip]
>> +		int old_dftl = net->ipv6.devconf_dflt->forwarding;
> 
> dflt, not dftl?
Good catch!
