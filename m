From: David Miller <davem@davemloft.net>
Subject: Re: [net 2/2] igb: Read flow control for i350 from correct EEPROM
 section
Date: Thu, 12 Sep 2013 16:25:31 -0400 (EDT)
Message-ID: <20130912.162531.1014568181662869444.davem@davemloft.net>
References: <1378839437-10965-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1378839437-10965-2-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: todd.fujinaka@intel.com, netdev@vger.kernel.org, gospo@redhat.com,
	sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37910 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755466Ab3ILUZd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Sep 2013 16:25:33 -0400
In-Reply-To: <1378839437-10965-2-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 10 Sep 2013 11:57:17 -0700

> From: "Fujinaka, Todd" <todd.fujinaka@intel.com>
> 
> Flow control is defined in the four EEPROM sections but the driver only reads
> from section 0.
> 
> Signed-off-by: Todd Fujinaka <todd.fujinaka@intel.com>
> Tested-by: Aaron Brown <aaron.f.brown@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
