From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [net-next] i40e: enable fdb add code, remove unused code
Date: Fri, 21 Nov 2014 06:50:50 +0200
Message-ID: <CAJ3xEMhRw=NLQOYAQ1X6UUm9nvpaJxcuVt_DTNiybAbDJG=qJw@mail.gmail.com>
References: <1416529802-16055-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f50.google.com ([209.85.218.50]:61955 "EHLO
	mail-oi0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756976AbaKUEuv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2014 23:50:51 -0500
Received: by mail-oi0-f50.google.com with SMTP id a141so3091239oig.23
        for <netdev@vger.kernel.org>; Thu, 20 Nov 2014 20:50:50 -0800 (PST)
In-Reply-To: <1416529802-16055-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 21, 2014 at 2:30 AM, Jeff Kirsher
<jeffrey.t.kirsher@intel.com> wrote:
> From: Jesse Brandeburg <jesse.brandeburg@intel.com>

> The fdb_add functionality is important to i40e because it is needed
> for a workaround to allow bridges to work correctly on the i40e
> hardware.

Can you please shed more light on the precise problem and solution? I
wonder if one or two of them are generic... so might can/need land
somewhere upper...

Or.
