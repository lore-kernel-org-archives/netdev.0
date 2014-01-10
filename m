From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 3/3] ss: add unix_seqpacket to the help message and the
 man page
Date: Thu, 9 Jan 2014 23:07:26 -0800
Message-ID: <20140109230726.0d73aadb@nehalam.linuxnetplumber.net>
References: <1389179628-22147-1-git-send-email-yamato@redhat.com>
	<1389179628-22147-3-git-send-email-yamato@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Masatake YAMATO <yamato@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:58358 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750800AbaAJHH3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 02:07:29 -0500
Received: by mail-pa0-f48.google.com with SMTP id lf10so2060553pab.7
        for <netdev@vger.kernel.org>; Thu, 09 Jan 2014 23:07:28 -0800 (PST)
In-Reply-To: <1389179628-22147-3-git-send-email-yamato@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed,  8 Jan 2014 20:13:48 +0900
Masatake YAMATO <yamato@redhat.com> wrote:

> Signed-off-by: Masatake YAMATO <yamato@redhat.com>
> ---
>  man/man8/ss.8 | 2 +-
>  misc/ss.c     | 2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)

All 3 applied to master since they can go directly in next release
(no dependency on net-next).
