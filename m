From: Paul Menzel <pmenzel@molgen.mpg.de>
Subject: Re: [bnx2] [Regression 4.8] Driver loading fails without firmware
Date: Tue, 25 Oct 2016 17:31:17 +0200
Message-ID: <fb79b944-a190-3c30-45eb-eacd51be9e7f@molgen.mpg.de>
References: <244cb42b-0fce-fe41-7b7c-babb51411e8c@molgen.mpg.de>
 <aa771485-b733-49fa-765c-9c2914d65605@hpe.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, Baoquan He <bhe@redhat.com>
To: Rick Jones <rick.jones2@hpe.com>,
        Sony Chacko <sony.chacko@qlogic.com>,
        Dept-HSGLinuxNICDev@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.molgen.mpg.de ([141.14.17.9]:59071 "EHLO mx1.molgen.mpg.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932696AbcJYPbV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 25 Oct 2016 11:31:21 -0400
In-Reply-To: <aa771485-b733-49fa-765c-9c2914d65605@hpe.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Rick,


On 10/25/16 17:24, Rick Jones wrote:
> On 10/25/2016 07:33 AM, Paul Menzel wrote:

>> A server with the Broadcom devices below, fails to load the drivers
>> because of missing firmware.
>
> I have run into the same sort of issue from time to time when going to a
> newer kernel.  A newer version of the driver wants a newer version of
> the firmware.  Usually, finding a package "out there" with the newer
> version of the firmware, and installing it onto the system is sufficient.

To my knowledge, the firmware files haven’t changed since years [1].


Kind regards,

Paul


[1] 
https://git.kernel.org/cgit/linux/kernel/git/firmware/linux-firmware.git/tree/bnx2
