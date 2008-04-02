From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: 2.6.25-rc6-git2: warn_on_slowpath for tcp_simple_retransmit
Date: Wed, 2 Apr 2008 11:10:38 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0804021110190.10371@wrl-59.cs.helsinki.fi>
References: <5a4c581d0804011528g786550c5sfd6bf90c0c37706@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>
To: Alessandro Suardi <alessandro.suardi@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:35631 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751685AbYDBIKk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2008 04:10:40 -0400
In-Reply-To: <5a4c581d0804011528g786550c5sfd6bf90c0c37706@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2 Apr 2008, Alessandro Suardi wrote:

> Found this in my FC6-based bittorrent box (K7-800 running
>  a 2.6.25-rc6-git2 kernel) this evening.
> 
> The kernel was upgraded two weeks ago to fix the bug
>  in which an USB VIA driver hammered the PCI bus
>  causing ATA disk performance to drop, and has been
>  running since then (it still is).
> 
> So it's actually 2.6.25-rc6-git2 plus patch as in here
> http://www.gossamer-threads.com/lists/linux/kernel/895506#895506
> 
> If there's anything useful I can do, just ask. Thanks !

Can you reproduce?

-- 
 i.
