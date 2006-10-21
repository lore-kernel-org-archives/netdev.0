From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] VIOC: Ethtool
Date: Sat, 21 Oct 2006 15:25:23 -0400
Message-ID: <453A7423.5080107@garzik.org>
References: <200610131056.28563.misha@fabric7.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: KERNEL Linux <linux-kernel@vger.kernel.org>,
	NETDEV Linux <netdev@vger.kernel.org>,
	Sriram Chidambaram <schidambaram@fabric7.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:640 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1422793AbWJUTZ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Oct 2006 15:25:26 -0400
To: misha@fabric7.com
In-Reply-To: <200610131056.28563.misha@fabric7.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Misha Tomushev wrote:
> The following is the ethtool patch for  VIOC Device Driver.
> 
> Signed-off-by: Misha Tomushev  <misha@fabric7.com>

ACK but does not apply to ethtool.git:


Applying 'add VIOC support'

Adds trailing whitespace.
.dotest/patch:50:#define VIOC_REGS_LINE_SIZE    sizeof(struct regs_line)
error: patch failed: Makefile.am:7
error: Makefile.am: patch does not apply
error: patch failed: ethtool-util.h:48
error: ethtool-util.h: patch does not apply
error: patch failed: ethtool.c:945
error: ethtool.c: patch does not apply

