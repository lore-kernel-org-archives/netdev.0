From: Chris Snook <chris.snook@gmail.com>
Subject: Re: [RFC 30/72] atl*: Move the Atheros drivers
Date: Sat, 25 Jun 2011 14:16:18 -0400
Message-ID: <BANLkTikLFOV=YTPKyutC4Soe9emaxM27rQ@mail.gmail.com>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com> <1309010363-22750-31-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Jay Cliburn <jcliburn@gmail.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:36740 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751678Ab1FYSQj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jun 2011 14:16:39 -0400
Received: by vxb39 with SMTP id 39so2598375vxb.19
        for <netdev@vger.kernel.org>; Sat, 25 Jun 2011 11:16:38 -0700 (PDT)
In-Reply-To: <1309010363-22750-31-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 25, 2011 at 9:58 AM, Jeff Kirsher
<jeffrey.t.kirsher@intel.com> wrote:
> Move the Atheros drivers into drivers/net/ethernet/atheros/ and
> make the necessary Kconfig and Makefile changes.
>
> CC: Jay Cliburn <jcliburn@gmail.com>
> CC: Chris Snook <chris.snook@gmail.com>
> CC: Jie Yang <jie.yang@atheros.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

I'm fine with this as long as the other ethernet maintainers are fine
with the whole series. I don't want to be making changes like this
unless it's to a new standard that's applied consistently.

-- Chris
