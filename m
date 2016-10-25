From: Rick Jones <rick.jones2@hpe.com>
Subject: Re: [bnx2] [Regression 4.8] Driver loading fails without firmware
Date: Tue, 25 Oct 2016 08:24:27 -0700
Message-ID: <aa771485-b733-49fa-765c-9c2914d65605@hpe.com>
References: <244cb42b-0fce-fe41-7b7c-babb51411e8c@molgen.mpg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Baoquan He <bhe@redhat.com>
To: Paul Menzel <pmenzel@molgen.mpg.de>,
        Sony Chacko <sony.chacko@qlogic.com>,
        Dept-HSGLinuxNICDev@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t3426.houston.hpe.com ([15.241.140.75]:5896 "EHLO
        g4t3426.houston.hpe.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751302AbcJYPY3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Oct 2016 11:24:29 -0400
In-Reply-To: <244cb42b-0fce-fe41-7b7c-babb51411e8c@molgen.mpg.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/25/2016 07:33 AM, Paul Menzel wrote:
> Dear Linux folks,
>
> A server with the Broadcom devices below, fails to load the drivers
> because of missing firmware.

I have run into the same sort of issue from time to time when going to a 
newer kernel.  A newer version of the driver wants a newer version of 
the firmware.  Usually, finding a package "out there" with the newer 
version of the firmware, and installing it onto the system is sufficient.

happy benchmarking,

rick jones
