From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [2.6 patch] drivers/net/qla3xxx.c: make 2 functions static
Date: Tue, 06 Mar 2007 06:20:17 -0500
Message-ID: <45ED4E71.4080106@garzik.org>
References: <20070305014927.GY3441@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-driver@qlogic.com, Ron Mercer <ron.mercer@qlogic.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Adrian Bunk <bunk@stusta.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:53341 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934082AbXCFLUV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2007 06:20:21 -0500
In-Reply-To: <20070305014927.GY3441@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adrian Bunk wrote:
> This patch makes two needlessly global functions static.
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>

applied


