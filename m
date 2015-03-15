From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v2 3/3] team: add support for
 ndo_switch_port_stp_update when team dev is a bridge port
Date: Sun, 15 Mar 2015 17:58:16 +0100
Message-ID: <20150315165816.GI2043@nanopsycho.orion>
References: <1426206598-29410-4-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sfeldma@gmail.com, davem@davemloft.net, netdev@vger.kernel.org
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:35846 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751512AbbCOQ6T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2015 12:58:19 -0400
Received: by wibg7 with SMTP id g7so21131526wib.1
        for <netdev@vger.kernel.org>; Sun, 15 Mar 2015 09:58:18 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1426206598-29410-4-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Mar 13, 2015 at 01:29:58AM CET, roopa@cumulusnetworks.com wrote:
>From: Roopa Prabhu <roopa@cumulusnetworks.com>
>
>This patch adds support for stp state offload netdev op to support the case
>where team dev is a bridge port and team slaves are switch ports.
>
>Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>

Acked-by: Jiri Pirko <jiri@resnulli.us>
