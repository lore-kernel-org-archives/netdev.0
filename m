From: Richard Weinberger <richard.weinberger@gmail.com>
Subject: Re: Issue with NFS over NAT since kernel 3.8.x
Date: Sat, 5 Oct 2013 13:32:59 +0200
Message-ID: <CAFLxGvx9CY9DPVgDsx+o+Ax8eGNC3jdwK=k51=RPHvJL96pH0A@mail.gmail.com>
References: <524FDCBE.9070407@c-s.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-net@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: leroy christophe <christophe.leroy@c-s.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f171.google.com ([209.85.128.171]:64163 "EHLO
	mail-ve0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751674Ab3JELdA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Oct 2013 07:33:00 -0400
In-Reply-To: <524FDCBE.9070407@c-s.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 5, 2013 at 11:32 AM, leroy christophe
<christophe.leroy@c-s.fr> wrote:
> Is there any change between 3.7 and 3.8 which could explain it ? How can I
> investigate this problem ?

You do a git-bisect to find the exact change.

-- 
Thanks,
//richard
