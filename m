From: Chris Friesen <cbf123@mail.usask.ca>
Subject: where is the ethernet device number determined?
Date: Thu, 12 May 2016 14:05:58 -0600
Message-ID: <5734E226.6040706@mail.usask.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out-so.shaw.ca ([64.59.136.137]:53002 "EHLO
	smtp-out-so.shaw.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750933AbcELUOM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2016 16:14:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi,

I hope this is a simple question...with legacy naming ethernet devices are named 
ethX.  Where is that X determined?  I've been looking in alloc_netdev_mqs() and 
friends, but haven't found it yet.

Thanks,
Chris
