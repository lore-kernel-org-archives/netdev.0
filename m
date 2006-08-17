From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: [PATCH 1/7] ip1000: update maintainer information
Date: Thu, 17 Aug 2006 11:26:16 +0300
Message-ID: <84144f020608170126n37574012u1dd6756ea6ead061@mail.gmail.com>
References: <1155843743.5006.3.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, akpm@osdl.org, dvrabel@cantab.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	david@pleyades.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.188]:44736 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S932309AbWHQI0S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Aug 2006 04:26:18 -0400
Received: by nf-out-0910.google.com with SMTP id o25so901326nfa
        for <netdev@vger.kernel.org>; Thu, 17 Aug 2006 01:26:16 -0700 (PDT)
To: "Jesse Huang" <jesse@icplus.com.tw>
In-Reply-To: <1155843743.5006.3.camel@localhost.localdomain>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jesse,

On 8/17/06, Jesse Huang <jesse@icplus.com.tw> wrote:
> From: Jesse Huang <jesse@icplus.com.tw>
>
> update maintainer information
>
> Change Logs:
>     update maintainer information

The patches are missing signed-off-by so please resend. I am starting
my vacation on friday so I suggest you send the whole driver as a
patch for review at netdev@vger.kernel.org for inclusion. I can apply
your patches to
git://git.kernel.org/pub/scm/linux/kernel/git/penberg/netdev-ipg-2.6.git
if you want, though. Only the first three patches apply and everything
starting from "ipg_config_autoneg rewrite' fail.

                                              Pekka
