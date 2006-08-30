From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: PATCH: br_stp.c:271: ignoring BPDUs if cost goes up
Date: Wed, 30 Aug 2006 12:02:33 -0700
Message-ID: <20060830120233.340d5afc@localhost.localdomain>
References: <44F5D334.7050205@bristyle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rajesh_mish@yahoo.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:48789 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751317AbWH3TCl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2006 15:02:41 -0400
To: Brian Braunstein <brian@bristyle.com>
In-Reply-To: <44F5D334.7050205@bristyle.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 30 Aug 2006 11:04:36 -0700
Brian Braunstein <brian@bristyle.com> wrote:

> PATCH
> problem at: br_stp.c:271
> problem: ignoring BPDUs if cost goes up
> 
> i was refered to email these addresses by the bridging code author.
> 
> please see the full problem description and patch at:
> http://mesh.calit2.net/calmesh/one/linux_kernel_modifications/bridge_ignoring_bpdus/
> 
> if you would like to have it attached or inline with the email instead 
> let me know.
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Okay, but please read Documentation/SubmittingPatches in kernel tree.
Format patch in line directly please.  Also, the changelog is now
maintained in the version control system (git) rather than the comments.


-- 
Stephen Hemminger <shemminger@osdl.org>
