From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH 3/3] bcm43xx-d80211: use host_gen_beacon_template
Date: Sat, 24 Jun 2006 13:17:45 +0200
Message-ID: <20060624131745.42cfb187@logostar.upir.cz>
References: <20060623181636.6DC1C483AD@silver.suse.cz>
	<200606232312.16289.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mb@bu3sch.de>, netdev@vger.kernel.org,
	Alexander Tsvyashchenko <lists@ndl.kiev.ua>
Return-path: <netdev-owner@vger.kernel.org>
Received: from r2u241.chello.upc.cz ([62.245.84.241]:48785 "EHLO cela.cz")
	by vger.kernel.org with ESMTP id S1752212AbWFXLRx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Jun 2006 07:17:53 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <200606232312.16289.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fri, 23 Jun 2006 23:12:15 +0200, Michael Buesch wrote:
> John, please apply.

Please do not apply the whole series yet, it is experimental and not well
tested (I wrote it in the introduction e-mail but will ensure I put it also
in subjects next time).

For example, I just realized that the first patch breaks scanning in STA
mode.

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
