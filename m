From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Clarification regarding TCP advertised window
Date: Thu, 20 Nov 2014 22:20:23 -0800
Message-ID: <1416550823.8629.92.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1768979683.134536.1416550026650.JavaMail.root@mail.cse.iitm.ac.in>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: cprasad@cse.iitm.ac.in
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f170.google.com ([209.85.223.170]:33848 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750766AbaKUGUZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2014 01:20:25 -0500
Received: by mail-ie0-f170.google.com with SMTP id rd18so4375499iec.1
        for <netdev@vger.kernel.org>; Thu, 20 Nov 2014 22:20:25 -0800 (PST)
In-Reply-To: <1768979683.134536.1416550026650.JavaMail.root@mail.cse.iitm.ac.in>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-11-21 at 11:37 +0530, cprasad@cse.iitm.ac.in wrote:
> Hi,
> I was looking at TCP packets on wireshark and I found that during a
> download the advertised window in an ack packet was exceeding the max
> value of tcp_rmem parameter. What could be the reason for that?

What about you provide exact values ?
