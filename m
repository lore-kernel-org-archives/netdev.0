From: Oleg <lego12239@yandex.ru>
Subject: Re: struct ip vs struct iphdr
Date: Fri, 5 May 2017 11:02:28 +0300
Message-ID: <20170505080228.GB8546@legohost>
References: <20170504164219.GA25287@legohost>
 <d56b2182-3c81-5c52-5d77-8be128088e1b@oracle.com>
Reply-To: Oleg <lego12239@yandex.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: Girish Moodalbail <girish.moodalbail@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward2j.cmail.yandex.net ([5.255.227.20]:32831 "EHLO
        forward2j.cmail.yandex.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752040AbdEEII4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 5 May 2017 04:08:56 -0400
Content-Disposition: inline
In-Reply-To: <d56b2182-3c81-5c52-5d77-8be128088e1b@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 04, 2017 at 10:08:46AM -0700, Girish Moodalbail wrote:
> Also, see this:
> 
> http://stackoverflow.com/questions/42840636/difference-between-struct-ip-and-struct-iphdr

  I saw this. But the answer say that struct ip and struct iphdr defined in
different places. However i see struct iphdr together with struct ip in
my netinet/ip.h. So, i thought that this answer may be inexact or incorrect.

  Thanks!

-- 
Олег Неманов (Oleg Nemanov)
