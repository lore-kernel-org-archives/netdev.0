From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next] net: add vxlan description
Date: Fri, 17 Jan 2014 16:35:23 -0800
Message-ID: <20140117163523.52bf53a2@nehalam.linuxnetplumber.net>
References: <1390004520-11465-1-git-send-email-jesse.brandeburg@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:47401 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751177AbaARAf0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jan 2014 19:35:26 -0500
Received: by mail-pa0-f46.google.com with SMTP id rd3so4795522pab.33
        for <netdev@vger.kernel.org>; Fri, 17 Jan 2014 16:35:26 -0800 (PST)
In-Reply-To: <1390004520-11465-1-git-send-email-jesse.brandeburg@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 17 Jan 2014 16:22:00 -0800
Jesse Brandeburg <jesse.brandeburg@intel.com> wrote:

> Add a description to the vxlan module, helping save the world
> from the minions of destruction and confusion.
> 
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> CC: Stephen Hemminger <stephen@networkplumber.org>

Sure. Someone should add this to GRE, SIT, IPIP and VTI as well.

Acked-by: Stephen Hemminger <stephen@networkplumber.org>
