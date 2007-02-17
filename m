From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/6] sky2: dont flush good pause frames
Date: Sat, 17 Feb 2007 15:32:02 -0500
Message-ID: <45D76642.7040804@garzik.org>
References: <20070216004028.943889000@linux-foundation.org> <20070216004141.678148000@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sk-drivers@lists.linux-foundation.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47831 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932728AbXBQUcE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Feb 2007 15:32:04 -0500
In-Reply-To: <20070216004141.678148000@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> Don't mark pause frames as errors. This problem caused transmitter not
> to pause and would effectively take out a gigabit switch because the
> it can't handle overrun. 
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

applied 1-6




