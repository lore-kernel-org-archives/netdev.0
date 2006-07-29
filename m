From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: SMSC LAN911x and LAN921x vendor driver
Date: Fri, 28 Jul 2006 17:38:05 -0700
Message-ID: <20060728173805.1d875993@localhost.localdomain>
References: <20060714115035.502d8edf@dxpl.pdx.osdl.net>
	<11540873333102-git-send-email-steve.glendinning@smsc.com>
	<20060728213841.GA14235@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Steve Glendinning <steve.glendinning@smsc.com>,
	netdev@vger.kernel.org, Ian Saturley <ian.saturley@smsc.com>,
	Bahadir Balban <Bahadir.Balban@arm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:58780 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1161397AbWG2Ai0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2006 20:38:26 -0400
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20060728213841.GA14235@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Could the tasklet be replaced by using NAPI (dev->poll) routine?
