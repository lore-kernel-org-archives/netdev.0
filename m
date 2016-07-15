From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH iproute2] ss: Add option to suppress header line
Date: Fri, 15 Jul 2016 12:58:23 -0600
Message-ID: <505633d0-0d1e-5e23-5de7-514b134381ff@cumulusnetworks.com>
References: <1468603245-4947-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:33806 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751312AbcGOS6Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2016 14:58:25 -0400
Received: by mail-pa0-f54.google.com with SMTP id fi15so41619608pac.1
        for <netdev@vger.kernel.org>; Fri, 15 Jul 2016 11:58:25 -0700 (PDT)
In-Reply-To: <1468603245-4947-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/15/16 11:20 AM, David Ahern wrote:
> Add option to suppress header line. When used the following line
> is not shown:
> "State  Recv-Q Send-Q     Local Address:Port  Peer Address:Port"
>
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ---
>  man/man8/ss.8 |  3 +++
>  misc/ss.c     | 28 +++++++++++++++++++---------
>  2 files changed, 22 insertions(+), 9 deletions(-)
>

This one I goofed and made relative to our branch.

if you are ok with the option I'll rebase to master branch.
