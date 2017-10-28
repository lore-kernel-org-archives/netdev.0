From: David Miller <davem@redhat.com>
Subject: Re: [PATCH net-next] nfp: inform the VF driver needs to be
 restarted after changing the MAC
Date: Sat, 28 Oct 2017 19:00:09 +0900 (KST)
Message-ID: <20171028.190009.1966295870087364316.davem@redhat.com>
References: <20171027003538.20314-1-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com,
        pablo.cascon@netronome.com
To: jakub.kicinski@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44102 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751430AbdJ1KAS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 28 Oct 2017 06:00:18 -0400
In-Reply-To: <20171027003538.20314-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <jakub.kicinski@netronome.com>
Date: Thu, 26 Oct 2017 17:35:38 -0700

> From: Pablo Cascón <pablo.cascon@netronome.com>
> 
> Add message to inform the VF MAC was changed and the need to restart
> the VF driver for the changes to be effective.
> 
> Signed-off-by: Pablo Cascón <pablo.cascon@netronome.com>
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>

Applied, thanks!
