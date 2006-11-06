From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 1/2] forcedeth: add mgmt unit support
Date: Mon, 06 Nov 2006 03:11:52 -0500
Message-ID: <454EEE48.8020201@pobox.com>
References: <45467D57.9060404@nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:1923 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1423571AbWKFIMC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Nov 2006 03:12:02 -0500
To: Ayaz Abdulla <aabdulla@nvidia.com>
In-Reply-To: <45467D57.9060404@nvidia.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ayaz Abdulla wrote:
> This patch adds support for the mgmt unit in certain chipsets. The MAC 
> and the mgmt unit share the PHY and therefore proper intialization 
> procedures are needed for them to maintain coexistense.
> 
> Signed-Off-By: Ayaz Abdulla <aabdulla@nvidia.com>

applied


