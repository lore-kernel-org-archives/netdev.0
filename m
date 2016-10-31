From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 12/15] ptp: use permission-specific DEVICE_ATTR variants
Date: Mon, 31 Oct 2016 10:30:21 +0100
Message-ID: <20161031093021.GA10489@localhost.localdomain>
References: <1477769829-22230-1-git-send-email-Julia.Lawall@lip6.fr>
 <1477769829-22230-13-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kernel-janitors@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Julia Lawall <Julia.Lawall@lip6.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:36219 "EHLO
        mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1763785AbcJaJa1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 05:30:27 -0400
Content-Disposition: inline
In-Reply-To: <1477769829-22230-13-git-send-email-Julia.Lawall@lip6.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 29, 2016 at 09:37:06PM +0200, Julia Lawall wrote:
> Use DEVICE_ATTR_RO for read only attributes.  This simplifies the
> source code, improves readbility, and reduces the chance of
> inconsistencies.

Acked-by: Richard Cochran <richardcochran@gmail.com>
