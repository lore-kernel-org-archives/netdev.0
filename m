From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH 01/26] et1310: kill pAdapter in favour of a sane name
Date: Tue, 25 Aug 2009 22:49:45 -0700
Message-ID: <20090826054945.GA25352@kroah.com>
References: <20090825145619.16176.68780.stgit@localhost.localdomain>
 <20090825145732.16176.83630.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Alan Cox <alan@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:57215 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756673AbZHZFvn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Aug 2009 01:51:43 -0400
Content-Disposition: inline
In-Reply-To: <20090825145732.16176.83630.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 25, 2009 at 03:57:36PM +0100, Alan Cox wrote:
> Signed-off-by: Alan Cox <alan@linux.intel.com>

Odd, every single hunk of this patch fails to apply to my tree :(

What did you diff it against? I have 4 et131x patches in my tree, but
they are all from you already.

confused,

greg k-h
