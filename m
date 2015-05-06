From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next 3/6] netns: rename peernet2id() to
 peernet2id_alloc()
Date: Wed, 6 May 2015 13:27:11 +0200
Message-ID: <20150506112711.GC25248@pox.localdomain>
References: <1430906288-5108-1-git-send-email-nicolas.dichtel@6wind.com>
 <1430906288-5108-4-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, ebiederm@xmission.com
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:37126 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750818AbbEFL1O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 07:27:14 -0400
Received: by widdi4 with SMTP id di4so18408712wid.0
        for <netdev@vger.kernel.org>; Wed, 06 May 2015 04:27:13 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1430906288-5108-4-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/06/15 at 11:58am, Nicolas Dichtel wrote:
> In a following commit, a new function will be introduced to only lookup for
> a nsid (no allocation if the nsid doesn't exist). To avoid confusion, the
> existing function is renamed.
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Acked-by: Thomas Graf <tgraf@suug.ch>
