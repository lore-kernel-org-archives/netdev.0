From: Maxim Levitsky <maximlevitsky@gmail.com>
Subject: Re: How I can reset TCP sockets after long suspend/resume cyscle
Date: Wed, 04 Jun 2008 18:34:10 +0300
Message-ID: <4846B5F2.8090805@gmail.com>
References: <200806011515.14103.maximlevitsky@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.154]:35935 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753446AbYFDPeR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2008 11:34:17 -0400
Received: by fg-out-1718.google.com with SMTP id 19so79621fgg.17
        for <netdev@vger.kernel.org>; Wed, 04 Jun 2008 08:34:15 -0700 (PDT)
In-Reply-To: <200806011515.14103.maximlevitsky@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Maxim Levitsky wrote:
> Hi,
> 
> Is there a way to close all TCP sockets before/after suspend to ram?
> 
> It is so annoying that after a long suspend/resume cycle all applications
> still wait for long closed connections.
> 
> Kmail/imap is the worst example here.
> 
> I tried to disable network interace, I tried even to remove its module
> with no luck.
> 
> Best regards,
> 	Maxim Levitsky


Anybody knows about this?

Best regards,
	Maxim Levitsky
