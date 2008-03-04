From: "=?UTF-8?Q?Rui_Tiago_Ca=C3=A7=C3=A3o_Matos?=" <rmatos@av.it.pt>
Subject: Re: [PATCH] Remove usage of C++ keyword 'class' on htb.h header.
Date: Tue, 4 Mar 2008 21:44:47 +0000
Message-ID: <eae3b3410803041344m57d00311x6d8652783c36fe9d@mail.gmail.com>
References: <1204655476-2663-1-git-send-email-rmatos@av.it.pt>
	 <1204655476-2663-2-git-send-email-rmatos@av.it.pt>
	 <20080304125332.7e4d3b3c.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org
To: "Randy Dunlap" <randy.dunlap@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.246]:26322 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757135AbYCDVot (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 16:44:49 -0500
Received: by an-out-0708.google.com with SMTP id d31so207803and.103
        for <netdev@vger.kernel.org>; Tue, 04 Mar 2008 13:44:48 -0800 (PST)
In-Reply-To: <20080304125332.7e4d3b3c.randy.dunlap@oracle.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/03/2008, Randy Dunlap <randy.dunlap@oracle.com> wrote:
> We generally prefer to see function parameter names present in prototypes.
>
>  What about the other 30 or so C++ keywords that the kernel uses?
>  Do you have a metric ton of more patches?

Sorry if I wasn't clear. This is for the userspace libnl.

Rui
