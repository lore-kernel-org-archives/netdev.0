From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 0/4] bridge-utils: build system fixes and cleanups
Date: Fri, 28 Feb 2014 10:17:20 -0800
Message-ID: <20140228101720.7a826230@nehalam.linuxnetplumber.net>
References: <1393239406-8504-1-git-send-email-mazo@telum.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andrey Mazo <mazo@telum.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f53.google.com ([209.85.160.53]:54202 "EHLO
	mail-pb0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751682AbaB1SRY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Feb 2014 13:17:24 -0500
Received: by mail-pb0-f53.google.com with SMTP id rp16so1079508pbb.40
        for <netdev@vger.kernel.org>; Fri, 28 Feb 2014 10:17:23 -0800 (PST)
In-Reply-To: <1393239406-8504-1-git-send-email-mazo@telum.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 24 Feb 2014 14:56:42 +0400
Andrey Mazo <mazo@telum.ru> wrote:

> This short patch series implements several enhancements to the bridge-utils
> build system.
> The first two patches had already been sent to the bridge list [1,2]
> but unfortunately got no response.
> I've recently sent the whole patch series to the bridge list [3]
> but forgot to CC netdev list.
> I appologize if you receive multiple copies of this series.
> 
> [1] http://lists.linuxfoundation.org/pipermail/bridge/2013-August/008535.html
> [2] http://lists.linuxfoundation.org/pipermail/bridge/2013-August/008536.html
> [3] http://lists.linuxfoundation.org/pipermail/bridge/2014-February/008711.html
> 
> Andrey Mazo (4):
>   bridge-utils: Abort compilation on error in any subdirectory
>   bridge-utils: Removed unused variable in doc/Makefile.in
>   bridge-utils: AC_OUTPUT should be used without arguments
>   bridge-utils: Pretty print configure help
> 
>  Makefile.in     |  4 ++--
>  configure.ac    | 12 ++++++++----
>  doc/Makefile.in |  2 --
>  3 files changed, 10 insertions(+), 8 deletions(-)
> 

Looks good, accepted.
