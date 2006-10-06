From: Matthew Wilcox <matthew@wil.cx>
Subject: Re: [PATCH] [TULIP] Fix section mismatch in de2104x.c
Date: Fri, 6 Oct 2006 12:45:17 -0600
Message-ID: <20061006184517.GL2563@parisc-linux.org>
References: <11601583542790-git-send-email-matthew@wil.cx> <4526A2ED.6030406@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Val Henson <val_henson@linux.intel.com>, netdev@vger.kernel.org,
	Helge Deller <deller@parisc-linux.org>,
	Kyle McMartin <kyle@parisc-linux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palinux.external.hp.com ([192.25.206.14]:24735 "EHLO
	mail.parisc-linux.org") by vger.kernel.org with ESMTP
	id S1422838AbWJFSpS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Oct 2006 14:45:18 -0400
To: Jeff Garzik <jeff@garzik.org>
Content-Disposition: inline
In-Reply-To: <4526A2ED.6030406@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 06, 2006 at 02:39:41PM -0400, Jeff Garzik wrote:
> I'm a bit blind, so help me out here...  what precisely is mismatched?
> 
> AFAICS everything is properly marked __init or __exit.

Wasn't my patch, but the markings are now consistent with tulip_core at least.
