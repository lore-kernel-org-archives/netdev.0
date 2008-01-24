From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Slow OOM in netif_RX function
Date: Thu, 24 Jan 2008 22:51:21 +0100
Message-ID: <20080124215121.GA6153@electric-eye.fr.zoreil.com>
References: <4798CAA9.1080005@obs.bg> <4798E32E.6080003@cosmosbay.com> <20080124211810.3E24A46E9A@smtp.obs.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "Ivan H. Dichev" <idichev@obs.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:57939 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751972AbYAXWHE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jan 2008 17:07:04 -0500
Content-Disposition: inline
In-Reply-To: <20080124211810.3E24A46E9A@smtp.obs.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ivan H. Dichev <idichev@obs.bg> :
[...]
> Any other ideas appreciated. 

Plot the slab values and the counters of the iptables rules against time ?

-- 
Ueimor
