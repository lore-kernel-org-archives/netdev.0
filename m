From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH 01/11] staging: r8188eu: Remove pointless thread_exit
 macro
Date: Fri, 20 Dec 2013 11:22:35 -0600
Message-ID: <52B47CDB.506@lwfinger.net>
References: <1387514323-4486-1-git-send-email-Larry.Finger@lwfinger.net> <1387514323-4486-2-git-send-email-Larry.Finger@lwfinger.net> <20131220165859.GA12829@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:59749 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753342Ab3LTRWj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 12:22:39 -0500
Received: by mail-pa0-f44.google.com with SMTP id fa1so2908974pad.3
        for <netdev@vger.kernel.org>; Fri, 20 Dec 2013 09:22:38 -0800 (PST)
In-Reply-To: <20131220165859.GA12829@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/20/2013 10:58 AM, Greg KH wrote:
> With this series applied, I get a ton of "unused variable" warnings, can
> you please fix them up now too?

Strange, but I don't get any. My compiler is gcc (SUSE Linux) 4.8.1 20130909 
[gcc-4_8-branch revision 202388] from openSUSE 13.1. What version are you using?

Larry
