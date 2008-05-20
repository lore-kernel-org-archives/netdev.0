From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3/8] bonding: Remove redundant argument from
 bond_create.
Date: Tue, 20 May 2008 14:46:06 -0700
Message-ID: <20080520144606.b7b9a799.akpm@linux-foundation.org>
References: <12110838143907-git-send-email-fubar@us.ibm.com>
	<12110838151824-git-send-email-fubar@us.ibm.com>
	<12110838151104-git-send-email-fubar@us.ibm.com>
	<12110838162313-git-send-email-fubar@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jgarzik@pobox.com, xemul@openvz.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:45041 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753733AbYETVqk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 May 2008 17:46:40 -0400
In-Reply-To: <12110838162313-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 17 May 2008 21:10:09 -0700
Jay Vosburgh <fubar@us.ibm.com> wrote:

> From: Pavel Emelyanov <xemul@openvz.org>
> 
> While we're fixing the bond_create, I hope it's OK to polish it
> a bit after the fixes.
> 
> The third argument is NULL at the first caller and is ignored by
> the second one, so remove it.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> Acked-by: Jay Vosburgh <fubar@us.ibm.com>

This should have been Signed-off-by:yourself, as described
in Documentation/SubmittingPatches.
