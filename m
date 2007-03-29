From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 6/7] qla3xxx: Adding support for the Agere PHY (ET1011C)
Date: Thu, 29 Mar 2007 08:35:30 -0400
Message-ID: <460BB292.2080709@garzik.org>
References: <20070326164650.GA3822@linux-7mw0.qlogic.org> <1174938234978-git-send-email-ron.mercer@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ron Mercer <ron.mercer@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:52611 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753400AbXC2Mfb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Mar 2007 08:35:31 -0400
In-Reply-To: <1174938234978-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ron Mercer wrote:
> This PHY support patch was written by Benjamin Li.
> Signed-off-by: Benjamin Li <benjamin.li@qlogic.com>
> Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
> ---
>  drivers/net/qla3xxx.c |  347 +++++++++++++++++++++++++++++++++++++++++++------
>  drivers/net/qla3xxx.h |   33 +++++-
>  2 files changed, 335 insertions(+), 45 deletions(-)

applied 5-7 to #upstream


