From: David Miller <davem@davemloft.net>
Subject: Re: [PatchV2 : PL25A1 Support - 1/3] whitespace
Date: Wed, 06 Apr 2011 13:17:39 -0700 (PDT)
Message-ID: <20110406.131739.242138705.davem@davemloft.net>
References: <1301456667-1648-1-git-send-email-simon@mungewell.org>
	<1302063406-13077-1-git-send-email-simon@mungewell.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh@suse.de, david-b@pacbell.net, sshtylyov@mvista.com,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: simon@mungewell.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1302063406-13077-1-git-send-email-simon@mungewell.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


There are some problems with this patch series:

1) Please compose your subject lines more correctly.  When I such these
   patches into GIT, everything in the initial "[]" brackets is removed
   and the commit header line for this patch (for example) ends up being
   just "whitespace".

   We want more than that.

   Try something like:

	Subject: [PATCH v2 1/3] usb: plusb: Whitespace.
	Subject: [PATCH v2 2/3] usb: plusb: Add PL25A1 support.
	Subject: [PATCH v2 3/3] usb: plusb: Add reset debugging.

2) Patch 2 doesn't apply cleanly to the current tree, you'll need to
   refresh these patches.

Thanks.
