From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V1 0/3] net/mlx4_core: Allow setting init-time
 device specific parameters
Date: Thu, 12 Mar 2015 14:09:42 -0400 (EDT)
Message-ID: <20150312.140942.100203943937808252.davem@davemloft.net>
References: <CAJL1qvHP0cLRVf53J9MuJrYCJLjE=mzEU70JofJ8zH_Yf-O16g@mail.gmail.com>
	<20150312090042.GB1092@kroah.com>
	<5501803D.8020101@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, hadarh@dev.mellanox.co.il,
	amirv@mellanox.com, netdev@vger.kernel.org, hadarh@mellanox.com,
	yevgenyp@mellanox.com, talal@mellanox.com,
	shannon.nelson@intel.com, dledford@redhat.com,
	greearb@candelatech.com, gregory.v.rose@intel.com,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	john.ronciak@intel.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38076 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750969AbbCLSJp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 14:09:45 -0400
In-Reply-To: <5501803D.8020101@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Thu, 12 Mar 2015 14:02:05 +0200

> So.. M2-- reading Dave's words I understand that he's against textual
> interfacessuch as configfs and prefers others. This brings two
> questions to the table (1) do we need to deprecate these textual
> interfaces / configfs and avoid using them for configuration purposes
> with new code? (2) does programmable interface such as netlink is the
> way to go for our purposes here (and elsewhere)?

Do not try to hijack a discussion about what interfaces you should be
using for your use case into a discussion about deprecating configfs.
