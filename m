From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 13/16] myri10ge: add routines for multislices
Date: Tue, 13 May 2008 01:47:46 -0400
Message-ID: <48292B82.5090304@garzik.org>
References: <482397A3.1050604@myri.com> <482398F6.3060902@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Brice Goglin <brice@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:42925 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755107AbYEMFrr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 May 2008 01:47:47 -0400
In-Reply-To: <482398F6.3060902@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brice Goglin wrote:
> Add several routines that multislices support will use.
> 
> Signed-off-by: Brice Goglin <brice@myri.com>
> Signed-off-by: Andrew Gallatin <gallatin@myri.com>
> ---
>  drivers/net/myri10ge/myri10ge.c |  256 ++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 256 insertions(+)

this is not really appropriate for the bug-fixes-only 2.6.26-rc.

I temporarily put patches 13-16 in netdev-2.6.git#upstream-myri, and 
will shove them into net-next once davem pulls in the myri bugfixes into 
net-next (or you guys have some alternate suggestions)


