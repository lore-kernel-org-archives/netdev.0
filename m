From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net-next] net: Lookup actual route when oif is VRF device
Date: Mon, 5 Oct 2015 12:10:12 -0600
Message-ID: <5612BD04.4040605@gmail.com>
References: <201510060144.B0K1B1ZG%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kbuild-all@01.org, netdev@vger.kernel.org
To: kbuild test robot <lkp@intel.com>,
	David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:35651 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750980AbbJESKO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 14:10:14 -0400
Received: by pacfv12 with SMTP id fv12so187198156pac.2
        for <netdev@vger.kernel.org>; Mon, 05 Oct 2015 11:10:13 -0700 (PDT)
In-Reply-To: <201510060144.B0K1B1ZG%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/5/15 12:01 PM, kbuild test robot wrote:
> Hi David,
>
> [auto build test ERROR on v4.3-rc4 -- if it's inappropriate base, please ignore]
>

net-next patches can *not* be applied to Linus' tree. If you are going 
to run the build bot for patches submitted to netdev, please be sure to 
apply those patches to net-next tree.

David
