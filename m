From: David Miller <davem@davemloft.net>
Subject: Re: sfuzz hanging on 2.6.18
Date: Thu, 12 Oct 2006 01:49:57 -0700 (PDT)
Message-ID: <20061012.014957.104033840.davem@davemloft.net>
References: <20061012073720.GB9274@redhat.com>
	<452DF2E7.5060501@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davej@redhat.com, netdev@vger.kernel.org, patrick@tykepenguin.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:58048
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1422824AbWJLIt6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Oct 2006 04:49:58 -0400
To: kaber@trash.net
In-Reply-To: <452DF2E7.5060501@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Thu, 12 Oct 2006 09:46:47 +0200

> Looks like unbalanced locking.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied and pushed to -stable, thanks Patrick.
