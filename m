From: Johannes Stezenbach <js@linuxtv.org>
Subject: Re: Updated sysctl documentation take #2
Date: Thu, 8 Jun 2006 01:56:31 +0200
Message-ID: <20060607235631.GA10688@linuxtv.org>
References: <20060607205316.bbb3c379.diegocg@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, akpm@osdl.org,
	netdev@vger.kernel.org, linux-xfs@oss.sgi.com, ecki@lina.inka.de,
	lkml@rtr.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from allen.werkleitz.de ([80.190.251.108]:60123 "EHLO
	allen.werkleitz.de") by vger.kernel.org with ESMTP id S932468AbWFGX4n
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Jun 2006 19:56:43 -0400
To: Diego Calleja <diegocg@gmail.com>
Content-Disposition: inline
In-Reply-To: <20060607205316.bbb3c379.diegocg@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 07, 2006, Diego Calleja wrote:
> Since people didn't like the "many small files" approach, I've moved
> it to directories containing index.txt files:
> 
> Documentation/sysctl/vm/index.txt
> Documentation/sysctl/net/core/index.txt

Why not just

Documentation/sysctl/vm.txt
Documentation/sysctl/net/core.txt

etc.?


Johannes
