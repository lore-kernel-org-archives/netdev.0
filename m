From: Viresh Kumar <viresh.kumar@linaro.org>
Subject: Re: [net-next:master 20/25] warning: (NET_DSA_TAG_DSA &&
 NET_DSA_TAG_EDSA && NET_DSA_TAG_TRAILER) selects NET_DSA which has unmet
 direct dependencies (NET && EXPERIMENTAL && NETDEVICES && !S390)
Date: Mon, 26 Nov 2012 11:43:06 +0530
Message-ID: <CAKohpo=r2ZTp5uSp_5duc+zwWvkkwr8dMbz+Yn=WC+ngFy3-0g@mail.gmail.com>
References: <50b2f66a.czw+uqRm3Q/zfbER%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: kbuild test robot <fengguang.wu@intel.com>,
	Ben Hutchings <bhutchings@solarflare.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:58888 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752311Ab2KZGNH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2012 01:13:07 -0500
Received: by mail-ie0-f174.google.com with SMTP id k11so5790519iea.19
        for <netdev@vger.kernel.org>; Sun, 25 Nov 2012 22:13:07 -0800 (PST)
In-Reply-To: <50b2f66a.czw+uqRm3Q/zfbER%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ben/Dave,

On 26 November 2012 10:26, kbuild test robot <fengguang.wu@intel.com> wrote:
> tree:   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
> head:   53d6841d225b93c20d561878637c3cd307c11648
> commit: 82167cb8c6b2f8166d5c7532e5ef4b5e0cc46a72 [20/25] net: dsa/slave: Fix compilation warnings
> config: make ARCH=s390 allmodconfig
>
> All warnings:
>
> warning: (NET_DSA_TAG_DSA && NET_DSA_TAG_EDSA && NET_DSA_TAG_TRAILER) selects NET_DSA which has unmet direct dependencies (NET && EXPERIMENTAL && NETDEVICES && !S390)
> warning: (NET_DSA_TAG_DSA && NET_DSA_TAG_EDSA && NET_DSA_TAG_TRAILER) selects NET_DSA which has unmet direct dependencies (NET && EXPERIMENTAL && NETDEVICES && !S390)
> --
> warning: (NET_DSA_TAG_DSA && NET_DSA_TAG_EDSA && NET_DSA_TAG_TRAILER) selects NET_DSA which has unmet direct dependencies (NET && EXPERIMENTAL && NETDEVICES && !S390)

I am not really sure how to fix this up. Can you help?

--
viresh
