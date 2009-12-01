From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [Bridge] notifier chain on br0
Date: Tue, 1 Dec 2009 08:32:02 -0800
Message-ID: <20091201083202.719890c6@nehalam>
References: <cfeab66d0912010626n43e2a971gdc8a23b976256c56@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bridge@lists.linux-foundation.org, netdev@vger.kernel.org
To: ratheesh k <ratheesh.ksz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:34627 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753665AbZLAQc5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2009 11:32:57 -0500
In-Reply-To: <cfeab66d0912010626n43e2a971gdc8a23b976256c56@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 1 Dec 2009 19:56:03 +0530
ratheesh k <ratheesh.ksz@gmail.com> wrote:

> Hi All ,
> 
>  i  have a software bridge br0 on eth0 and eth1 . Can i use NETLINK
> sockets to get ip address change notification on br0 .???
> 
> Thanks,
> Ratheesh

Netlink reports all interfaces including br0
