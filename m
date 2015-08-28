From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next 1/4] ip_tunnels: convert the mode field of
 ip_tunnel_info to flags
Date: Fri, 28 Aug 2015 20:08:38 +0200
Message-ID: <20150828200838.3f530f9a@griffin>
References: <cover.1440771116.git.jbenc@redhat.com>
	<21cc14223253b50addb96dd054d02c3f7f2681ac.1440771116.git.jbenc@redhat.com>
	<CALnjE+r4CW2+Rmi-qmnO+1oyQJ-YO_xiPVxO+3ygY9AEZnrWhw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Thomas Graf <tgraf@suug.ch>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41665 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751811AbbH1SIm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Aug 2015 14:08:42 -0400
In-Reply-To: <CALnjE+r4CW2+Rmi-qmnO+1oyQJ-YO_xiPVxO+3ygY9AEZnrWhw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 28 Aug 2015 10:29:55 -0700, Pravin Shelar wrote:
> geneve module also needs to be updated.

Right, the rebase on top of your patches is not complete. I'll send v2.

Thanks,

 Jiri

-- 
Jiri Benc
