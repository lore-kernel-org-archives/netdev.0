From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next v2 4/4] openvswitch: IPv6 support for
 ovs_tunnel_get_egress_info
Date: Fri, 2 Oct 2015 08:00:41 +0200
Message-ID: <20151002080041.52017d26@griffin>
References: <cover.1443710454.git.jbenc@redhat.com>
	<8eeae62b794d6d7486cedd8178414d2fdfb6e4f8.1443710454.git.jbenc@redhat.com>
	<CALnjE+o-ou=Vpv8_e20-CyRMA62ceGiDOZuSaRU9Qwb_WBBP8Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	Jesse Gross <jesse@nicira.com>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55908 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750767AbbJBGAo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Oct 2015 02:00:44 -0400
In-Reply-To: <CALnjE+o-ou=Vpv8_e20-CyRMA62ceGiDOZuSaRU9Qwb_WBBP8Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 1 Oct 2015 17:11:56 -0700, Pravin Shelar wrote:
> I dont see point of adding this code when IPv6 sampling not support by
> the patch series.

It was requested by Jesse:
http://article.gmane.org/gmane.linux.network/380348

I don't mind leaving this and the previous patch out, it's actually
what I did in v1.

 Jiri

-- 
Jiri Benc
