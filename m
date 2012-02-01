From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] bna: add readme file
Date: Wed, 1 Feb 2012 11:56:07 -0800
Message-ID: <20120201115607.10679ac3@s6510.linuxnetplumber.net>
References: <1327712205-17609-1-git-send-email-huangj@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<adapter_linux_open_src_team@brocade.com>
To: Jing Huang <huangj@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:52962 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756558Ab2BAT4N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Feb 2012 14:56:13 -0500
In-Reply-To: <1327712205-17609-1-git-send-email-huangj@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 27 Jan 2012 16:56:45 -0800
Jing Huang <huangj@brocade.com> wrote:

> This patch adds bna driver readme file to Documentation/networking.
> 
> Signed-off-by: Jing Huang <huangj@brocade.com>

Please do send the firmware to David Woodhouse <dwmw2@infradead.org>
to put in the linux-firmware tree. 

 git://git.kernel.org/pub/scm/linux/kernel/git/dwmw2/linux-firmware.git


If you do that every distribution will pick it
up from there.
