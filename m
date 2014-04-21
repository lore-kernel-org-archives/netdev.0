From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [net 0/7][pull request] Intel Wired LAN Driver Updates
Date: Mon, 21 Apr 2014 23:15:16 +0300
Message-ID: <CAJZOPZLpgT41yfjUDD_8qoOCLWsEAT-XfywaKh_KTTFOMqEdRA@mail.gmail.com>
References: <1397872767-4001-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<20140421.125858.1669714683420708606.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f182.google.com ([209.85.216.182]:50138 "EHLO
	mail-qc0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752607AbaDUUPR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2014 16:15:17 -0400
Received: by mail-qc0-f182.google.com with SMTP id e16so4404090qcx.41
        for <netdev@vger.kernel.org>; Mon, 21 Apr 2014 13:15:17 -0700 (PDT)
In-Reply-To: <20140421.125858.1669714683420708606.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Fri, 18 Apr 2014 18:59:20 -0700
>> Jesse's i40e patch fixes an issue reported by Eric Dumazet that the
>> i40e driver was allowing the hardware to replicate the PSH flag on
>> all segments of a TSO operation.  With this fix, we are now configuring
>> the CWR bit to only be set in the first packet of a TSO and we
>> enable TSO_ECN in order to advertise to the stack that we do the right
>> thing on the wire.

Hi Jeff, was this report sent over netdev? pointer will be great

Or.
