From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH v3 net-next 6/8] openvswitch: Use Geneve device.
Date: Tue, 25 Aug 2015 19:48:58 +0200
Message-ID: <20150825174858.GE3707@pox.localdomain>
References: <1440438195-5695-1-git-send-email-pshelar@nicira.com>
 <1440438195-5695-7-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:32817 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751816AbbHYRtA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 13:49:00 -0400
Received: by wijn1 with SMTP id n1so691443wij.0
        for <netdev@vger.kernel.org>; Tue, 25 Aug 2015 10:48:59 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1440438195-5695-7-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/24/15 at 10:43am, Pravin B Shelar wrote:
> With help of tunnel metadata mode OVS can directly use
> Geneve devices to implement Geneve tunnels.
> This patch removes all of the OVS specific Geneve code
> and make OVS use a Geneve net_device. Basic geneve vport
> is still there to handle compatibility with current
> userspace application.
> 
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
> Reviewed-by: Jesse Gross <jesse@nicira.com>

Acked-by: Thomas Graf <tgraf@suug.ch>
