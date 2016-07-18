From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [iproute PATCH v5 5/5] Makefile: Allow to override CC
Date: Mon, 18 Jul 2016 10:10:42 -0600
Message-ID: <9e98dfb1-c5a3-e43f-8b38-2e842e48fd4b@cumulusnetworks.com>
References: <1468853325-9260-1-git-send-email-phil@nwl.cc>
 <1468853325-9260-6-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Julien Floret <julien.floret@6wind.com>,
	David Laight <David.Laight@ACULAB.COM>, netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>, Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f179.google.com ([209.85.223.179]:36226 "EHLO
	mail-io0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751441AbcGRQKp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2016 12:10:45 -0400
Received: by mail-io0-f179.google.com with SMTP id b62so163821694iod.3
        for <netdev@vger.kernel.org>; Mon, 18 Jul 2016 09:10:44 -0700 (PDT)
In-Reply-To: <1468853325-9260-6-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/18/16 8:48 AM, Phil Sutter wrote:
> This makes it easier to build iproute2 with a custom compiler.
>
> While at it, make HOSTCC default to the value of CC if not explicitly
> set elsewhere.
>
> Signed-off-by: Phil Sutter <phil@nwl.cc>
> ---
>  Makefile | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)

Acked-by: David Ahern <dsa@cumulusnetworks.com>
