From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH] RDS: Add AF and PF defines for RDS sockets
Date: Tue, 26 Aug 2008 06:16:28 +0200
Message-ID: <75428E88-423C-492F-AE72-3157D968DC04@holtmann.org>
References: <1219723337.6864.3.camel@lute.groveronline.com>
Mime-Version: 1.0 (Apple Message framework v928.1)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andy Grover <andy.grover@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:53786 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750830AbYHZEQb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2008 00:16:31 -0400
In-Reply-To: <1219723337.6864.3.camel@lute.groveronline.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andy,

> RDS is a reliable datagram protocol used for IPC on Oracle
> database clusters. This adds address and protocol family numbers
> for it.

and where is the protocol? Adding new constants without posting the  
implementation normally doesn't fly anymore.

Regards

Marcel

