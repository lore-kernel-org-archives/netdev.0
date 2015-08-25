From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH v3 net-next 4/8] geneve: Make dst-port configurable.
Date: Tue, 25 Aug 2015 19:47:08 +0200
Message-ID: <20150825174708.GC3707@pox.localdomain>
References: <1440438195-5695-1-git-send-email-pshelar@nicira.com>
 <1440438195-5695-5-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:33291 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751512AbbHYRrK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 13:47:10 -0400
Received: by wijn1 with SMTP id n1so647354wij.0
        for <netdev@vger.kernel.org>; Tue, 25 Aug 2015 10:47:09 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1440438195-5695-5-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/24/15 at 10:43am, Pravin B Shelar wrote:
> Add netlink interface to configure Geneve UDP port number.
> So that user can configure it for a Gevene device.
> 
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
> Reviewed-by: Jesse Gross <jesse@nicira.com>

Acked-by: Thomas Graf <tgraf@suug.ch>
