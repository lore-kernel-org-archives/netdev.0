From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] ethtool: add register dump support for SMSC LAN911x/LAN921x
Date: Thu, 26 Jul 2007 13:45:19 -0400
Message-ID: <46A8DDAF.4070300@garzik.org>
References: <11846126802524-git-send-email-steve.glendinning@smsc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ian Saturley <ian.saturley@smsc.com>
To: Steve Glendinning <steve.glendinning@smsc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:49690 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761997AbXGZRpX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Jul 2007 13:45:23 -0400
In-Reply-To: <11846126802524-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Steve Glendinning wrote:
> This patch adds support for SMSC's LAN911x and LAN921x families of
> embedded ethernet controllers to ethtool's dump registers (-d) command.
> 
> This patch is for use with the smsc911x driver.
> 
> Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
> ---
>  Makefile.am    |    3 +-
>  ethtool-util.h |    4 ++
>  ethtool.c      |    2 +
>  smsc911x.c     |   90 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
>  4 files changed, 98 insertions(+), 1 deletions(-)
>  create mode 100644 smsc911x.c

applied


