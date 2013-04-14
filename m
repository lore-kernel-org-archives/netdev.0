From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next 6/9] qlcnic: Fix recurring firmware dump
 collection
Date: Sun, 14 Apr 2013 12:55:50 +0200
Message-ID: <20130414105550.GE30385@electric-eye.fr.zoreil.com>
References: <1365874114-6759-1-git-send-email-shahed.shaikh@qlogic.com>
 <1365874114-6759-7-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Dept_NX_Linux_NIC_Driver@qlogic.com,
	Sony Chacko <sony.chacko@qlogic.com>
To: Shahed Shaikh <shahed.shaikh@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:44086 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750873Ab3DNKz5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Apr 2013 06:55:57 -0400
Content-Disposition: inline
In-Reply-To: <1365874114-6759-7-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Shahed Shaikh <shahed.shaikh@qlogic.com> :
> From: Sony Chacko <sony.chacko@qlogic.com>
> 
> Firmware dump is collected after a non-recoverable Tx timeout error.
> Reset dump collection flag and context reset flag in virtual NIC
> mode to prevent recurring dump collection and context resets.

Candidate for net instead of net-next ?

-- 
Ueimor
