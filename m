From: "Bart Van Assche" <bart.vanassche@gmail.com>
Subject: Re: BUG/ spinlock lockup, 2.6.24
Date: Fri, 15 Feb 2008 16:24:56 +0100
Message-ID: <e2e108260802150724k4e5e6089mcb603b524157a9bc@mail.gmail.com>
References: <20080215150044.M24489@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Denys Fedoryshchenko" <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from el-out-1112.google.com ([209.85.162.182]:19884 "EHLO
	el-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757072AbYBOPY6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Feb 2008 10:24:58 -0500
Received: by el-out-1112.google.com with SMTP id v27so617869ele.23
        for <netdev@vger.kernel.org>; Fri, 15 Feb 2008 07:24:57 -0800 (PST)
In-Reply-To: <20080215150044.M24489@visp.net.lb>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2008/2/15 Denys Fedoryshchenko <denys@visp.net.lb>:
>  I have random crashes, at least once per week. It is very difficult to catch
>  error message, and only recently i setup netconsole. Now i got crash, but
>  there is no traceback and only single line came over netconsole, mentioned
>  before.

Did you already run memtest ? You can run memtest by booting from the
Knoppix CD-ROM or DVD. Most Linux distributions also have included
memtest on their bootable distribution CD's/DVD's.

Bart Van Assche.
