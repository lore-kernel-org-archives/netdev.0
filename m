From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] SMSC LAN911x and LAN921x vendor driver
Date: Wed, 18 Jul 2007 18:38:00 -0400
Message-ID: <469E9648.6050209@garzik.org>
References: <11846120522745-git-send-email-steve.glendinning@smsc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ian Saturley <ian.saturley@smsc.com>,
	Bahadir Balban <Bahadir.Balban@arm.com>,
	Dustin Mcintire <dustin@sensoria.com>,
	Bill Gatliff <bgat@billgatliff.com>
To: Steve Glendinning <steve.glendinning@smsc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:33119 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758650AbXGRWiF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jul 2007 18:38:05 -0400
In-Reply-To: <11846120522745-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Where is the hard_start_xmit/TX-completion locking?


