From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [iproute PATCH v4 5/5] Makefile: Allow to override CC
Date: Fri, 15 Jul 2016 09:33:54 -0600
Message-ID: <b0aac6f8-b5c4-ad4e-b01e-8755ccf28b20@cumulusnetworks.com>
References: <1468435639-6892-1-git-send-email-phil@nwl.cc>
 <1468435639-6892-6-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Julien Floret <julien.floret@6wind.com>,
	David Laight <David.Laight@ACULAB.COM>, netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>, Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f43.google.com ([209.85.214.43]:35573 "EHLO
	mail-it0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751241AbcGOPd4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2016 11:33:56 -0400
Received: by mail-it0-f43.google.com with SMTP id u186so21777836ita.0
        for <netdev@vger.kernel.org>; Fri, 15 Jul 2016 08:33:56 -0700 (PDT)
In-Reply-To: <1468435639-6892-6-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/13/16 12:47 PM, Phil Sutter wrote:
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
