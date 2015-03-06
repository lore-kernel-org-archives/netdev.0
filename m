From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 3/3] team: add support for
 ndo_switch_port_stp_update when team dev is a bridge port
Date: Fri, 6 Mar 2015 07:56:07 +0100
Message-ID: <20150306065607.GC2004@nanopsycho.orion>
References: <1425614658-43701-4-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sfeldma@gmail.com, davem@davemloft.net, netdev@vger.kernel.org
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f50.google.com ([74.125.82.50]:38806 "EHLO
	mail-wg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751803AbbCFG4K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Mar 2015 01:56:10 -0500
Received: by wghl18 with SMTP id l18so10859199wgh.5
        for <netdev@vger.kernel.org>; Thu, 05 Mar 2015 22:56:09 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1425614658-43701-4-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Mar 06, 2015 at 05:04:18AM CET, roopa@cumulusnetworks.com wrote:
>From: Roopa Prabhu <roopa@cumulusnetworks.com>
>
>This patch adds support for stp state offload netdev op to support the case
>where team dev is a bridge port and team slaves are switch ports.
>
>Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>

Acked-by: Jiri Pirko <jiri@resnulli.us>
