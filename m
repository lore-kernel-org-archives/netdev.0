From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCHv3 net 2/4] openvswitch: Clarify conntrack COMMIT behaviour
Date: Tue, 20 Oct 2015 10:37:40 +0200
Message-ID: <20151020083740.GA25435@pox.localdomain>
References: <1445307540-6786-1-git-send-email-joestringer@nicira.com>
 <1445307540-6786-2-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, pshelar@nicira.com, jrajahalme@nicira.com
To: Joe Stringer <joestringer@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:34428 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752551AbbJTIhn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2015 04:37:43 -0400
Received: by wikq8 with SMTP id q8so34959797wik.1
        for <netdev@vger.kernel.org>; Tue, 20 Oct 2015 01:37:42 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1445307540-6786-2-git-send-email-joestringer@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/19/15 at 07:18pm, Joe Stringer wrote:
> The presence of this attribute does not modify the ct_state for the
> current packet, only future packets. Make this more clear in the header
> definition.
> 
> Signed-off-by: Joe Stringer <joestringer@nicira.com>

Acked-by: Thomas Graf <tgraf@suug.ch>
