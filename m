From: Sricharan R <sricharan@codeaurora.org>
Subject: Re: [REGRESSION next-20170426] Commit 09515ef5ddad ("of/acpi:
 Configure dma operations at probe time for platform/amba/pci bus devices")
 causes oops in mvneta
Date: Thu, 27 Apr 2017 14:24:22 +0530
Message-ID: <28fbd821-c975-48e0-92bf-2d3938286cc5@codeaurora.org>
References: <20170426181508.687b52af@gmail.com>
 <20170427084427.GV5077@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>,
        Bjorn Helgaas <bhelgaas@google.com>,
        linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-pci@vger.kernel.org,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        netdev@vger.kernel.org
To: Joerg Roedel <jroedel@suse.de>,
        Ralph Sennhauser <ralph.sennhauser@gmail.com>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <20170427084427.GV5077@suse.de>
Content-Language: en-US
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Joerg,

On 4/27/2017 2:14 PM, Joerg Roedel wrote:
> Sricharan,
> 
> On Wed, Apr 26, 2017 at 06:15:08PM +0200, Ralph Sennhauser wrote:
>> Commit 09515ef5ddad ("of/acpi: Configure dma operations at probe time
>> for platform/amba/pci bus devices") causes a kernel panic as in the log
>> below on an armada-385. Reverting the commit fixes the issue.
> 
> Any insight here? I tend to revert the patch in my tree, or is there a
> quick and easy fix?

I am checking on this manually to see what could be going wrong in the
driver. From logs i could not conclude directly. I will need some
more testing help (i will ask for) to root cause this.

Regards,
 Sricharan

> 
> 
> 
> 	Joerg
> 

-- 
"QUALCOMM INDIA, on behalf of Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum, hosted by The Linux Foundation
