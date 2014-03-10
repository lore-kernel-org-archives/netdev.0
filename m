From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH V3] ss: Add support for retrieving SELinux contexts
Date: Mon, 10 Mar 2014 13:24:04 -0700
Message-ID: <20140310132404.6d792d30@nehalam.linuxnetplumber.net>
References: <1394188612-3662-1-git-send-email-richard_c_haines@btinternet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov
To: Richard Haines <richard_c_haines@btinternet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:46709 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751231AbaCJUYH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 16:24:07 -0400
Received: by mail-pd0-f175.google.com with SMTP id x10so7531918pdj.34
        for <netdev@vger.kernel.org>; Mon, 10 Mar 2014 13:24:06 -0700 (PDT)
In-Reply-To: <1394188612-3662-1-git-send-email-richard_c_haines@btinternet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri,  7 Mar 2014 10:36:52 +0000
Richard Haines <richard_c_haines@btinternet.com> wrote:

> The process SELinux contexts can be added to the output using the -Z
> option. Using the -z option will show the process and socket contexts (see
> the man page for details).
> For netlink sockets: if valid process show process context, if pid = 0
> show kernel initial context, if unknown show "unavailable".
> 
> Signed-off-by: Richard Haines <richard_c_haines@btinternet.com>

Applied, thanks
