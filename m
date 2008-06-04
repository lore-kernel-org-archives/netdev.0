From: "Alexander Beregalov" <a.beregalov@gmail.com>
Subject: Re: WARNING: at net/ipv4/tcp_input.c:2213
Date: Thu, 5 Jun 2008 02:29:24 +0400
Message-ID: <a4423d670806041529q6911f68fq68ee9ed8f8f50139@mail.gmail.com>
References: <a4423d670806041450h17a2d3b1w40ea9ff8550a4b11@mail.gmail.com>
	 <20080604.145244.07802877.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: kernel-testers@vger.kernel.org, netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.236]:46851 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754818AbYFDW3Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2008 18:29:25 -0400
Received: by wx-out-0506.google.com with SMTP id h29so236240wxd.4
        for <netdev@vger.kernel.org>; Wed, 04 Jun 2008 15:29:24 -0700 (PDT)
In-Reply-To: <20080604.145244.07802877.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2008/6/5 David Miller <davem@davemloft.net>:
> From: "Alexander Beregalov" <a.beregalov@gmail.com>
> Date: Thu, 5 Jun 2008 01:50:49 +0400
>
>> I have got the following message:
>
> We need to know the exact kernel version you were running, what
> kinds of things the system was doing at the time, etc.
>

It is 2.6.26-rc3-00332-gcbff290.
Host runs as a NFS server and rtorrent client.
That is all network activity on it.
I do not know what system was doing at this time, I have found this
warning only after some time.
