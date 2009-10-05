From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [PATCH 0/4][RFC]: coding convention for CCID-struct prefixes
Date: Mon, 5 Oct 2009 13:23:59 +0200
Message-ID: <20091005112359.GB5156@gerrit.erg.abdn.ac.uk>
References: <1254739993-5051-1-git-send-email-gerrit@erg.abdn.ac.uk> <20091005.035815.238234647.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: acme@redhat.com, dccp@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:47573 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758706AbZJELY5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Oct 2009 07:24:57 -0400
Content-Disposition: inline
In-Reply-To: <20091005.035815.238234647.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| After Arnaldo takes a look, I can add this as-is to net-next-2.6
This should work, they have been compile/sparse-tested and apply cleanly on net-2.6.

I am waiting for the feedback also in order to rebuild the test tree; and have
informed CCID-4 developers (CCID-4 subtree) about this.
