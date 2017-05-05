From: Oleg <lego12239@yandex.ru>
Subject: Re: struct ip vs struct iphdr
Date: Fri, 5 May 2017 10:48:48 +0300
Message-ID: <20170505074848.GA8546@legohost>
References: <20170504164219.GA25287@legohost>
 <20170504165248.GI7300@oracle.com>
Reply-To: Oleg <lego12239@yandex.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward4m.cmail.yandex.net ([5.255.216.22]:36858 "EHLO
        forward4m.cmail.yandex.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752690AbdEEHzt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 5 May 2017 03:55:49 -0400
Content-Disposition: inline
In-Reply-To: <20170504165248.GI7300@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 04, 2017 at 12:52:48PM -0400, Sowmini Varadhan wrote:
> BSD vs linux?
> 
> struct ip is a BSD-ism, intended to be used if you were porting
> some BSD app.

  Thanks!

-- 
Олег Неманов (Oleg Nemanov)
