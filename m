From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] can: add support for Janz VMOD-ICAN3 Intelligent
 CAN module
Date: Tue, 30 Mar 2010 23:46:11 -0700 (PDT)
Message-ID: <20100330.234611.50622716.davem@davemloft.net>
References: <1269881932-3803-3-git-send-email-iws@ovro.caltech.edu>
	<4BB1B2DA.60002@grandegger.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: iws@ovro.caltech.edu, linux-kernel@vger.kernel.org,
	socketcan-core@lists.berlios.de, netdev@vger.kernel.org,
	sameo@linux.intel.com
To: wg@grandegger.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4BB1B2DA.60002@grandegger.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Wolfgang Grandegger <wg@grandegger.com>
Date: Tue, 30 Mar 2010 10:14:18 +0200

> Ira W. Snyder wrote:
>> The Janz VMOD-ICAN3 is a MODULbus daughterboard which fits onto any
>> MODULbus carrier board. It is an intelligent CAN controller with a
>> microcontroller and associated firmware.
>> 
>> Signed-off-by: Ira W. Snyder <iws@ovro.caltech.edu>
> 
> Acked-by: Wolfgang Grandegger <wg@grandegger.com>

Since this driver depends upon the MFD stuff and that goes
through other maintainers, just toss this CAN driver in
via whatever tree the MFD thing goes through and add my:

Acked-by: David S. Miller <davem@davemloft.net>

Thanks!
