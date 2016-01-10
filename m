From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next 1/3] openvswitch: clean up unused function
Date: Sun, 10 Jan 2016 11:16:41 +0100
Message-ID: <20160110101641.GA1190@pox.localdomain>
References: <1452380831-11258-2-git-send-email-sakiwit@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Pravin Shelar <pshelar@nicira.com>,
	dev@openvswitch.org
To: J??an Sacren <sakiwit@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:33989 "EHLO
	mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751554AbcAJKQn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jan 2016 05:16:43 -0500
Received: by mail-wm0-f46.google.com with SMTP id u188so182675230wmu.1
        for <netdev@vger.kernel.org>; Sun, 10 Jan 2016 02:16:43 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1452380831-11258-2-git-send-email-sakiwit@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/09/16 at 04:07pm, J??an Sacren wrote:
> From: Jean Sacren <sakiwit@gmail.com>
> 
> commit 6b001e682e90 ("openvswitch: Use Geneve device.")
> 
> The commit above deleted the only call site of ovs_tunnel_route_lookup()
> and now that function is not used any more. So let's delete the function
> definition as well.
> 
> Signed-off-by: Jean Sacren <sakiwit@gmail.com>

Acked-by: Thomas Graf <tgraf@suug.ch>
