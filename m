From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next v4 1/4] openvswitch: Move tunnel destroy
 function to oppenvswitch module.
Date: Sun, 9 Aug 2015 18:09:45 +0200
Message-ID: <20150809160945.GD3113@pox.localdomain>
References: <1438830750-6512-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:37500 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933047AbbHIQJs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Aug 2015 12:09:48 -0400
Received: by wibhh20 with SMTP id hh20so121254681wib.0
        for <netdev@vger.kernel.org>; Sun, 09 Aug 2015 09:09:46 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1438830750-6512-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/05/15 at 08:12pm, Pravin B Shelar wrote:
> This function will be used in gre and geneve vport implementations.
> 
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>

Acked-by: Thomas Graf <tgraf@suug.ch>
