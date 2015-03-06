From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] tc class: Show class names from file
Date: Thu, 5 Mar 2015 16:27:16 -0800
Message-ID: <20150305162716.6145cdf2@urahara>
References: <1425400878-7608-1-git-send-email-vadim4j@gmail.com>
	<20150303095845.5aa844a0@urahara>
	<20150303185249.GA2227@angus-think.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:32782 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752452AbbCFA1U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 19:27:20 -0500
Received: by pdev10 with SMTP id v10so24055560pde.0
        for <netdev@vger.kernel.org>; Thu, 05 Mar 2015 16:27:20 -0800 (PST)
In-Reply-To: <20150303185249.GA2227@angus-think.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 3 Mar 2015 20:52:49 +0200
Vadim Kochan <vadim4j@gmail.com> wrote:

> Sorry I did not get how this adds the dependency for berkely db ?
> Would you please help me to understand the problem ?
> 
> Thanks,

Sorry, i was thinking and typing at same time.
I was thinking this would be a good case for using a berkely db for
1000's of classes, but a file works ok.
