From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 1/5] wil6210: Convert to Kbuild
Date: Thu, 10 Apr 2014 13:14:10 +0200
Message-ID: <1397128450.4757.19.camel@jlt4.sipsolutions.net>
References: <1396946179-11677-1-git-send-email-qca_vkondrat@qca.qualcomm.com>
	 <1397059601.14321.19.camel@joe-AO722> <534654D7.4080904@suse.cz>
	 <1949326.Ead3K8R9Y2@lx-vladimir> (sfid-20140410_122336_448287_D92FCC12)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Michal Marek <mmarek@suse.cz>, Joe Perches <joe@perches.com>,
	"John W . Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, wil6210@qca.qualcomm.com,
	netdev <netdev@vger.kernel.org>
To: Vladimir Kondratiev <qca_vkondrat@qca.qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:46865 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934795AbaDJLOh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2014 07:14:37 -0400
In-Reply-To: <1949326.Ead3K8R9Y2@lx-vladimir> (sfid-20140410_122336_448287_D92FCC12)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-04-10 at 13:23 +0300, Vladimir Kondratiev wrote:

> Accordingly to this, would you say I should drop this patch and go with
> GNUmakefile + Makefile for internal development? I am pretty neutral with
> this, just need to know what is the proper way.

Or you could just use the backports project for that :)

johannes
