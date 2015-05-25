From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH v3 net-next 1/2] rocker: remove unused rocker_port
 parameter from rocker_port_kfree
Date: Mon, 25 May 2015 08:32:07 +0200
Message-ID: <20150525063207.GA2081@nanopsycho.orion>
References: <1432531716-9189-1-git-send-email-simon.horman@netronome.com>
 <1432531716-9189-2-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Scott Feldman <sfeldma@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f43.google.com ([74.125.82.43]:36667 "EHLO
	mail-wg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751828AbbEYGcL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 May 2015 02:32:11 -0400
Received: by wgbgq6 with SMTP id gq6so64842627wgb.3
        for <netdev@vger.kernel.org>; Sun, 24 May 2015 23:32:10 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1432531716-9189-2-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, May 25, 2015 at 07:28:35AM CEST, simon.horman@netronome.com wrote:
>Remove unused rocker_port parameter from rocker_port_kfree.
>Also remove the rocker_port parameter from callers of rocker_port_kfree
>where the parameter it is now unused.
>
>Signed-off-by: Simon Horman <simon.horman@netronome.com>
>Acked-by: Scott Feldman <sfeldma@gmail.com>

Acked-by: Jiri Pirko <jiri@resnulli.us>
