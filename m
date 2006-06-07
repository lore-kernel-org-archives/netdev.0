From: Daniel Drake <dsd@gentoo.org>
Subject: Re: [patch] workaround zd1201 interference problem
Date: Wed, 07 Jun 2006 17:22:07 +0100
Message-ID: <4486FD2F.8040205@gentoo.org>
References: <20060607140045.GB1936@elf.ucw.cz> <20060607160828.0045e7f5@griffin.suse.cz> <20060607141536.GD1936@elf.ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>, linville@tuxdriver.com,
	kernel list <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta07-winn.ispmail.ntl.com ([81.103.221.47]:55819 "EHLO
	mtaout01-winn.ispmail.ntl.com") by vger.kernel.org with ESMTP
	id S932289AbWFGQVT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Jun 2006 12:21:19 -0400
To: Pavel Machek <pavel@suse.cz>
In-Reply-To: <20060607141536.GD1936@elf.ucw.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pavel Machek wrote:
> Well, I'll try _enable() alone, but it seems to me that _enable()
> command is needed to initialize radio properly. I do not think we can
> get much further without firmware sources...

If you can formulate a proper and technical description of the issue 
(and exactly what is needed to workaround it), I can contact ZyDAS for 
you. They have been very helpful with ZD1211.

Daniel
