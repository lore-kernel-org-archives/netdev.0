From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [patch] Fix type of prism2_hostapd_param crypt.alg
Date: Thu, 21 Sep 2006 21:27:17 +0200
Message-ID: <20060921212717.3b346bb3@logostar.upir.cz>
References: <20060907161554.GA9120@devicescape.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:1971 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1751481AbWIUT1U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2006 15:27:20 -0400
To: David Kimdon <david.kimdon@devicescape.com>
In-Reply-To: <20060907161554.GA9120@devicescape.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 7 Sep 2006 09:15:54 -0700, David Kimdon wrote:
> crypt.alg is a string, use the correct type.

Applied to my tree. Thanks for the patch!

 Jiri

-- 
Jiri Benc
SUSE Labs
