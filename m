From: Junchang Wang <junchangwang@gmail.com>
Subject: Re: Question about way that NICs deliver packets to the kernel
Date: Fri, 16 Jul 2010 15:35:24 +0800
Message-ID: <AANLkTikEid83BVi1zpiB1ljlyJI7_5KzL7Y1a9dlqreN@mail.gmail.com>
References: <20100715142418.GA26491@host-a-229.ustcsz.edu.cn>
	<20100715211249.GA7278@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:56609 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935713Ab0GPHfZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jul 2010 03:35:25 -0400
Received: by iwn7 with SMTP id 7so1854752iwn.19
        for <netdev@vger.kernel.org>; Fri, 16 Jul 2010 00:35:24 -0700 (PDT)
In-Reply-To: <20100715211249.GA7278@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> It is a simple, straightforward fix against a 8169 hardware bug.
>
> See commit c0cd884af045338476b8e69a61fceb3f34ff22f1.
>
Fortunately, it seems my device is unaffected by this issue. :)

Thanks Francois.

-- 
--Junchang
