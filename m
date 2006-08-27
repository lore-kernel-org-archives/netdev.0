From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: Re: 2.6.18-rc4-mm[1,2,3] -- Network card not getting assigned an
 "eth" device name
Date: Sun, 27 Aug 2006 09:30:17 -0700
Message-ID: <44F1C899.4020505@goop.org>
References: <a44ae5cd0608270007gc6a919fx9e36562d8023635d@mail.gmail.com> <20060827001943.c559d37d.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Miles Lane <miles.lane@gmail.com>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw.goop.org ([64.81.55.164]:60364 "EHLO mail.goop.org")
	by vger.kernel.org with ESMTP id S932167AbWH0QaV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Aug 2006 12:30:21 -0400
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20060827001943.c559d37d.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton wrote:
> Jeremy reported that a while back too.  I do not know what is causing it
> and as far as I know no net developers have yet looked into it.
>   

It went away with -rc4-mm[23] for me...

    J
