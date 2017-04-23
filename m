From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next 00/11][pull request] 10GbE Intel Wired LAN Driver
 Updates 2017-04-20
Date: Sat, 22 Apr 2017 20:41:58 -0700
Message-ID: <58FC2286.1090805@gmail.com>
References: <20170421015029.18994-1-jeffrey.t.kirsher@intel.com>
 <20170421.141809.1159225304098548850.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com
To: David Miller <davem@davemloft.net>, jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:34763 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1427472AbdDWDmV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 22 Apr 2017 23:42:21 -0400
Received: by mail-it0-f66.google.com with SMTP id 193so7776872itm.1
        for <netdev@vger.kernel.org>; Sat, 22 Apr 2017 20:42:21 -0700 (PDT)
In-Reply-To: <20170421.141809.1159225304098548850.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-04-21 11:18 AM, David Miller wrote:
> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Thu, 20 Apr 2017 18:50:18 -0700
> 
>> John adds XDP support (yeah!) for ixgbe.
> 
> As excited and eager as I am about this, I want to see the build regression
> for PAGE_SIZE>=8192 fixed before I pull this.
> 
> Thanks.
> 

Dang :(

Jeff, Alex sent you a fix already for this, but Jakub had a few nice
improvements. I'm thinking the easiest thing to do is for me to merge Alex's fix
and Jakubs comments and resend the patches.

Thanks,
John
