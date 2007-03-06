From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [2.6 patch] make drivers/net/s2io.c:vlan_strip_flag static
Date: Tue, 06 Mar 2007 06:20:11 -0500
Message-ID: <45ED4E6B.50000@garzik.org>
References: <20070305014925.GX3441@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Sivakumar Subramani <sivakumar.subramani@neterion.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Adrian Bunk <bunk@stusta.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:53332 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934080AbXCFLUO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2007 06:20:14 -0500
In-Reply-To: <20070305014925.GX3441@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adrian Bunk wrote:
> This patch makes the needlessly global vlan_strip_flag static.
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>

applied


