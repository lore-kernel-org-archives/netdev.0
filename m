From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] cnic: Update the rcu_access_pointer() usages
Date: Wed, 29 Oct 2014 15:07:57 -0400 (EDT)
Message-ID: <20141029.150757.1756336970085651001.davem@davemloft.net>
References: <1414473495-24790-1-git-send-email-nilesh.javali@qlogic.com>
	<1414473495-24790-2-git-send-email-nilesh.javali@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dept-GELinuxNICDev@qlogic.com,
	sudarsana.kalluru@qlogic.com, vikas.chaudhary@qlogic.com,
	giridhar.malavali@qlogic.com, tej.parkash@qlogic.com
To: nilesh.javali@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45622 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754482AbaJ2TIA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2014 15:08:00 -0400
In-Reply-To: <1414473495-24790-2-git-send-email-nilesh.javali@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nilesh Javali <nilesh.javali@qlogic.com>
Date: Tue, 28 Oct 2014 01:18:15 -0400

> From: Tej Parkash <tej.parkash@qlogic.com>
> 
> 1. Remove the rcu_read_lock/unlock around rcu_access_pointer
> 2. Replace the rcu_dereference with rcu_access_pointer
> 
> Signed-off-by: Tej Parkash <tej.parkash@qlogic.com>

Applied.
