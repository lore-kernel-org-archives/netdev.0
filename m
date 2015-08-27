From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH v5 net-next 6/8] openvswitch: Use Geneve device.
Date: Thu, 27 Aug 2015 11:19:25 +0200
Message-ID: <20150827091925.GE18481@pox.localdomain>
References: <1440658015-13028-1-git-send-email-pshelar@nicira.com>
 <1440658015-13028-7-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:33965 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752010AbbH0JT1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 05:19:27 -0400
Received: by widdq5 with SMTP id dq5so71548034wid.1
        for <netdev@vger.kernel.org>; Thu, 27 Aug 2015 02:19:26 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1440658015-13028-7-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/26/15 at 11:46pm, Pravin B Shelar wrote:
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
