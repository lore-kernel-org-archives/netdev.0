From: Jiri Benc <jbenc@suse.cz>
Subject: Re: d80211: ieee80211_hw handlers in atomic context
Date: Thu, 5 Oct 2006 17:39:16 +0200
Message-ID: <20061005173916.4ff86336@griffin.suse.cz>
References: <4523DA7D.2080604@web.de>
	<200610051700.31171.IvDoorn@gmail.com>
	<45252102.8030402@web.de>
	<200610051732.39319.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jan Kiszka <jan.kiszka@web.de>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:21396 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S932134AbWJEPjS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Oct 2006 11:39:18 -0400
To: Ivo van Doorn <ivdoorn@gmail.com>
In-Reply-To: <200610051732.39319.IvDoorn@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 5 Oct 2006 17:32:39 +0200, Ivo van Doorn wrote:
> Well I currently have no time to check it, but can
> config_interface handler still be called from interrupt context or has this also been fixed?

Will be fixed by the sta_timer conversion as well.

 Jiri

-- 
Jiri Benc
SUSE Labs
