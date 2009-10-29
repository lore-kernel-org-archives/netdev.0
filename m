From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: SRIOV driver for 82599
Date: Thu, 29 Oct 2009 07:40:59 -0700
Message-ID: <9929d2390910290740o7aed3e0er411e72ee3012a783@mail.gmail.com>
References: <be5d34890910090003s4c518c44q3ae395d0efbeb225@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Satish Chowdhury <satish.chowdhury@oneconvergence.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f42.google.com ([209.85.160.42]:55110 "EHLO
	mail-pw0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754195AbZJ2Okz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2009 10:40:55 -0400
Received: by pwj9 with SMTP id 9so79065pwj.21
        for <netdev@vger.kernel.org>; Thu, 29 Oct 2009 07:41:00 -0700 (PDT)
In-Reply-To: <be5d34890910090003s4c518c44q3ae395d0efbeb225@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 9, 2009 at 00:03, Satish Chowdhury
<satish.chowdhury@oneconvergence.com> wrote:
> Hi,
>
> I want to test the SRIOV functionality of Intel 82599 based NIC card.
> Is there a version of ixgbe driver with SRIOV functionality support
> and is there a ixgbe VF driver?
>
> Thanks
> -Satish
> --

Not currently.  We are currently working on the patches to add SRIOV support.

-- 
Cheers,
Jeff
