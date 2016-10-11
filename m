From: Eric Garver <e@erig.me>
Subject: Re: [PATCH net 3/3] openvswitch: add NETIF_F_HW_VLAN_STAG_TX to
 internal dev
Date: Tue, 11 Oct 2016 13:41:41 -0400
Message-ID: <20161011174141.GZ25403@egarver>
References: <cover.1476111550.git.jbenc@redhat.com>
 <688ddda46c331c1b85450d6f28b1441af6cee1de.1476111550.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, pravin shelar <pshelar@ovn.org>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50632 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752870AbcJKSGf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 11 Oct 2016 14:06:35 -0400
Content-Disposition: inline
In-Reply-To: <688ddda46c331c1b85450d6f28b1441af6cee1de.1476111550.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 10, 2016 at 05:02:44PM +0200, Jiri Benc wrote:
> The internal device does support 802.1AD offloading since 018c1dda5ff1
> ("openvswitch: 802.1AD Flow handling, actions, vlan parsing, netlink
> attributes").
> 
> Signed-off-by: Jiri Benc <jbenc@redhat.com>

Acked-by: Eric Garver <e@erig.me>
