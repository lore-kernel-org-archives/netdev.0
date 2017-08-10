From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH RFC 0/2] stap: Socket tap
Date: Thu, 10 Aug 2017 13:26:51 -0600
Message-ID: <09a36d95-84d0-d91b-225b-d3234ad6c363@gmail.com>
References: <20170807221204.15724-1-tom@quantonium.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: rohit@quantonium.net
To: Tom Herbert <tom@quantonium.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:34730 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752639AbdHJT0x (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2017 15:26:53 -0400
Received: by mail-pg0-f66.google.com with SMTP id y192so1334917pgd.1
        for <netdev@vger.kernel.org>; Thu, 10 Aug 2017 12:26:53 -0700 (PDT)
In-Reply-To: <20170807221204.15724-1-tom@quantonium.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/7/17 4:12 PM, Tom Herbert wrote:
> A socket tap is enabled on socket using SO_ULP socket option with
> ulp type "stap". The socket option takes ULP specific configuration

How about sktap instead of stap since stap has a history of referring to
system tap?
