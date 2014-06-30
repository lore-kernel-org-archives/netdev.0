From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 2/2] net: sctp: only warn in
 proc_sctp_do_alpha_beta if write
Date: Mon, 30 Jun 2014 15:04:50 +0200
Message-ID: <20140630130450.GB2941@minipsycho.orion>
References: <1404129129-23270-1-git-send-email-dborkman@redhat.com>
 <1404129129-23270-3-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f172.google.com ([74.125.82.172]:62629 "EHLO
	mail-we0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751314AbaF3NEy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jun 2014 09:04:54 -0400
Received: by mail-we0-f172.google.com with SMTP id u57so8074089wes.3
        for <netdev@vger.kernel.org>; Mon, 30 Jun 2014 06:04:52 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1404129129-23270-3-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Jun 30, 2014 at 01:52:09PM CEST, dborkman@redhat.com wrote:
>Only warn if the value is written to alpha or beta. We don't care
>emitting a one-time warning when only reading it.
>
>Reported-by: Jiri Pirko <jpirko@redhat.com>
>Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Reviewed-by: Jiri Pirko <jiri@resnulli.us>
