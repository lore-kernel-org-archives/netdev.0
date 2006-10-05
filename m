From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: d80211: ieee80211_hw handlers in atomic context
Date: Thu, 5 Oct 2006 17:39:28 +0200
Message-ID: <200610051739.28926.IvDoorn@gmail.com>
References: <4523DA7D.2080604@web.de> <200610051732.39319.IvDoorn@gmail.com> <20061005173916.4ff86336@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jan Kiszka <jan.kiszka@web.de>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.185]:2679 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S932145AbWJEPk1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Oct 2006 11:40:27 -0400
Received: by nf-out-0910.google.com with SMTP id o25so821134nfa
        for <netdev@vger.kernel.org>; Thu, 05 Oct 2006 08:40:25 -0700 (PDT)
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20061005173916.4ff86336@griffin.suse.cz>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 05 October 2006 17:39, Jiri Benc wrote:
> On Thu, 5 Oct 2006 17:32:39 +0200, Ivo van Doorn wrote:
> > Well I currently have no time to check it, but can
> > config_interface handler still be called from interrupt context or has this also been fixed?
> 
> Will be fixed by the sta_timer conversion as well.

Excellent news. :D

Thanks.

Ivo
