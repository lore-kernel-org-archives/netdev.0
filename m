From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH] ptp: ptp_pch depends on x86_32
Date: Tue, 17 Jun 2014 13:26:55 +0200
Message-ID: <20140617112655.GB7147@netboy>
References: <20140617115920.677401c3@endymion.delvare>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jean Delvare <jdelvare@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:61015 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752233AbaFQL1A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2014 07:27:00 -0400
Received: by mail-wi0-f180.google.com with SMTP id hi2so5623716wib.13
        for <netdev@vger.kernel.org>; Tue, 17 Jun 2014 04:26:59 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20140617115920.677401c3@endymion.delvare>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 17, 2014 at 11:59:20AM +0200, Jean Delvare wrote:
> The ptp_pch driver is for a companion chip to the Intel Atom E600
> series processors. These are 32-bit x86 processors so the driver is
> only needed on X86_32.

Sounds reasonable to me.

Acked-by: Richard Cochran <richardcochran@gmail.com>
