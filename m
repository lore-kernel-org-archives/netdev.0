From: NandaKumar <heramba85@gmail.com>
Subject: Re: Default TCP Options creating problems
Date: Sat, 28 Jan 2012 08:11:19 +0530
Message-ID: <4F23604F.90402@gmail.com>
References: <4F22B17A.2080809@gmail.com>  <1327675774.2220.13.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>  <4F22C81A.8090800@gmail.com> <1327677618.32615.1.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:49936 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752351Ab2A1CAn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2012 21:00:43 -0500
Received: by pbaa10 with SMTP id a10so2115475pba.19
        for <netdev@vger.kernel.org>; Fri, 27 Jan 2012 18:00:42 -0800 (PST)
In-Reply-To: <1327677618.32615.1.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/27/2012 8:50 PM, Eric Dumazet wrote:
> If you disable all options but tcp timestamps, what happens ? 

No, it doesn't work. I disabled SACK and window scaling. The connection 
gets established immediately once I disable tcp_timestamps. It may be 
problem with ISP. I am still awaiting their response. Not sure what sort 
of filtering they use for TCP Timestamps.

Thank you for your time.

Regards,
Nandakumar
