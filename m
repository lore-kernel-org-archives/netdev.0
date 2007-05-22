From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] [-mm] ACPI: export ACPI events via netlink
Date: Tue, 22 May 2007 07:03:45 -0400
Message-ID: <1179831825.4121.30.camel@localhost>
References: <1179827251.7707.29.camel@localhost.localdomain>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-acpi@vger.kernel.org, lenb@kernel.org, netdev@vger.kernel.org
To: Zhang Rui <rui.zhang@intel.com>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <1179827251.7707.29.camel@localhost.localdomain>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Zhang Rui,

Really cool stuff. Can you instead use genetlink?
http://linux-net.osdl.org/index.php/Generic_Netlink_HOWTO 
should help. And if you have more questions post on netdev (not lk).

cheers,
jamal

On Tue, 2007-22-05 at 17:47 +0800, Zhang Rui wrote:
> From: Zhang Rui <rui.zhang@intel.com>
> 
> Export ACPI events via netlink.
> A netlink message is broadcasted when an ACPI event is generated.
> 


