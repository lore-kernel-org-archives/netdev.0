From: Greg KH <greg@kroah.com>
Subject: Re: [stable] [stable-2.6.32.y] ixgbe: fix for 82599 erratum on
 Header Splitting
Date: Tue, 8 Mar 2011 11:48:55 -0800
Message-ID: <20110308194855.GB21865@kroah.com>
References: <1299366890-10333-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: gregkh@suse.de, Don Skidmore <donald.c.skidmore@intel.com>,
	stable@kernel.org, netdev@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:35563 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752257Ab1CHT7s (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Mar 2011 14:59:48 -0500
Content-Disposition: inline
In-Reply-To: <1299366890-10333-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 05, 2011 at 03:14:50PM -0800, Jeff Kirsher wrote:
> From: Don Skidmore <donald.c.skidmore@intel.com>
> 
> We have found a hardware erratum on 82599 hardware that can lead to
> unpredictable behavior when Header Splitting mode is enabled.  So
> we are no longer enabling this feature on affected hardware.
> 
> This is an updated version of the following commit which applies to the stable
> linux-2.6.32.y tree:

Applied, thanks.

greg k-h
