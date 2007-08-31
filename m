From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 07/12] sky2: use net_device internal stats
Date: Fri, 31 Aug 2007 09:43:37 -0400
Message-ID: <46D81B09.6080107@pobox.com>
References: <20070829193922.078561651@linux-foundation.org> <20070829195843.025028477@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:56962 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965156AbXHaNnj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Aug 2007 09:43:39 -0400
In-Reply-To: <20070829195843.025028477@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

NAK -- grep around net/core, you want ->get_stats()



