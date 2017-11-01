From: Eric Garver <e@erig.me>
Subject: Re: [PATCH net-next v15] openvswitch: enable NSH support
Date: Wed, 1 Nov 2017 11:21:16 -0400
Message-ID: <20171101152116.GS22092@dev-rhel7>
References: <1509508981-66202-1-git-send-email-yi.y.yang@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, dev@openvswitch.org, jbenc@redhat.com,
        pshelar@ovn.org, davem@davemloft.net
To: Yi Yang <yi.y.yang@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34342 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933147AbdKAPVT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 1 Nov 2017 11:21:19 -0400
Content-Disposition: inline
In-Reply-To: <1509508981-66202-1-git-send-email-yi.y.yang@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 01, 2017 at 12:03:01PM +0800, Yi Yang wrote:
> v14->v15
>  - Check size in nsh_hdr_from_nlattr
>  - Fixed four small issues pointed out By Jiri and Eric

Thanks Yi.

Acked-by: Eric Garver <e@erig.me>
