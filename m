From: David Ahern <dsahern@gmail.com>
Subject: Re: [RFC] iproute: Add support for extended ack to rtnl_talk
Date: Thu, 4 May 2017 08:27:35 -0600
Message-ID: <7315b681-9c78-4bc1-ab74-64509ab5887d@gmail.com>
References: <20170503235638.31116-1-stephen@networkplumber.org>
 <590AF624.6090808@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>,
        Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f49.google.com ([74.125.83.49]:35257 "EHLO
        mail-pg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754726AbdEDO1i (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 4 May 2017 10:27:38 -0400
Received: by mail-pg0-f49.google.com with SMTP id o3so9428832pgn.2
        for <netdev@vger.kernel.org>; Thu, 04 May 2017 07:27:38 -0700 (PDT)
In-Reply-To: <590AF624.6090808@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/4/17 3:36 AM, Daniel Borkmann wrote:
> What is the clear benefit/rationale of outsourcing this to
> libmnl? I always was the impression we should strive for as little
> dependencies as possible?

+1
