From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Reproducible data corruption with sendfile+vsftp - splice	regression?
Date: Fri, 30 Nov 2007 10:26:54 -0800
Message-ID: <475055EE.9060105@hp.com>
References: <pan.2007.11.29.23.42.52.661624@wizards.de>	<474FC4D9.3020506@cosmosbay.com> <pan.2007.11.30.09.20.24.737500@wizards.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Holger Hoffstaette <holger@wizards.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:40762 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758306AbXK3S04 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Nov 2007 13:26:56 -0500
In-Reply-To: <pan.2007.11.30.09.20.24.737500@wizards.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Could the corruption be seen in a tcpdump trace prior to transmission 
(ie taken on the sender) or was it only seen after the data passed out 
the NIC?

rick jones
