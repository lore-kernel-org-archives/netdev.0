From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: ixgbe driver fails occasionally since
 ee98b577e7711d5890ded2c7b05578a29512bd39
Date: Thu, 23 Oct 2014 19:48:32 +0000
Message-ID: <87618083B2453E4A8714035B62D679925016872B@FMSMSX105.amr.corp.intel.com>
References: <20141023140625.GD1480@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: Scott Harrison <scoharr2@cisco.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:2303 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751912AbaJWTse convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Oct 2014 15:48:34 -0400
In-Reply-To: <20141023140625.GD1480@cisco.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: netdev-owner@vger.kernel.org [mailto:netdev-
>owner@vger.kernel.org] On Behalf Of Scott Harrison
>Sent: Thursday, October 23, 2014 7:06 AM
>To: netdev@vger.kernel.org
>Subject: ixgbe driver fails occasionally since ee98b577e7711d5890ded2c7b05578a29512bd39
>
>Hi,
>
>I was asked to raise this issue here.
>
>https://bugzilla.kernel.org/show_bug.cgi?id=86591
>
>lspci ->
>
>03:00.0 Ethernet controller: Intel Corporation 82599EB 10-Gigabit SFI/SFP+ Network Connection (rev 01)
>03:00.1 Ethernet controller: Intel Corporation 82599EB 10-Gigabit SFI/SFP+ Network Connection (rev 01)
>
>With the fibre 10Gbs SFP occasionally on reboot we get
>
>[   15.104726] ixgbe 0000:03:00.0 eth0: detected SFP+: 5
>[   19.735155] ixgbe 0000:03:00.0 eth0: setup link failed with code -14

The error message is from an ethtool command. Where you trying to set the speed to a certain value?

Thanks,
Emil
