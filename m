From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4][RFC]: coding convention for CCID-struct prefixes
Date: Mon, 05 Oct 2009 03:58:15 -0700 (PDT)
Message-ID: <20091005.035815.238234647.davem@davemloft.net>
References: <ccid_coding_convention>
	<1254739993-5051-1-git-send-email-gerrit@erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: acme@redhat.com, dccp@vger.kernel.org, netdev@vger.kernel.org
To: gerrit@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54712
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932621AbZJEK6U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2009 06:58:20 -0400
In-Reply-To: <1254739993-5051-1-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon,  5 Oct 2009 12:53:09 +0200

> this codifies new naming scheme discussed at netconf. Can you please have a
> look and indicate whether you are ok with the set?
> 
> They are divided into 4 for readability, but can be combined into
> one large patch if agreed.

This looks like an improvement to me, I guess.

You can keep it as 4 patches.

After Arnaldo takes a look, I can add this as-is to net-next-2.6
if you like.
